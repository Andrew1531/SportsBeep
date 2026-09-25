require 'json'
require 'time'

module OpticOdds
  # Pure, read-only adapter for OpticOdds MLB fixture/odds and result snapshots.
  # A snapshot is scoped to ONE provider fixture; it never joins separate games.
  class MlbSnapshot
    class InvalidPayload < ArgumentError; end

    SAMPLES = {
      'royals_guardians_odds_48' => 'Pasted--data-id-F075D920FFCA-game-id-81005-35183-2024-08-27-15_1790352290451.txt',
      'royals_guardians_odds_2' => 'Pasted--data-id-F075D920FFCA-game-id-81005-35183-2024-08-27-15_1790352302689.txt',
      'tigers_astros_team' => 'Pasted--data-sport-id-baseball-name-Baseball--1790352317848_1790352317848.txt',
      'cubs_pirates_players' => 'Pasted--data-sport-id-baseball-name-Baseball--1790352332775_1790352332776.txt'
    }.freeze

    # Only lossless, context-specific correspondences with the original scoring IDs.
    BATTER = {
      'batting_walks' => Mlb::Stats::WALKS.id, 'doubles' => Mlb::Stats::DOUBLES.id,
      'batting_hit_by_pitch' => Mlb::Stats::HIT_BY_PITCH.id,
      'home_runs' => Mlb::Stats::HOME_RUNS.id, 'runs' => Mlb::Stats::RUNS.id,
      'rbi' => Mlb::Stats::RBIS.id, 'stolen_bases' => Mlb::Stats::STOLEN_BASES.id,
      'triples' => Mlb::Stats::TRIPLES.id
    }.freeze
    PITCHER = {
      'pitching_walks' => Mlb::Stats::WALKS.id, 'hits_allowed' => Mlb::Stats::HITS_ALLOWED.id,
      'innings_pitched' => Mlb::Stats::INNINGS_PITCHED.id,
      'strikeouts' => Mlb::Stats::STRIKE_OUTS.id
    }.freeze

    def self.samples
      SAMPLES.map do |label, filename|
        path = Rails.root.join('..', 'attached_assets', filename)
        parse(File.read(path), source: label)
      end
    end

    def self.parse(raw, source: nil)
      payload = raw.is_a?(String) ? JSON.parse(raw) : raw
      fail_payload('expected object with one data entry') unless payload.is_a?(Hash) &&
        payload['data'].is_a?(Array) && payload['data'].length == 1
      entry = payload['data'].first
      fail_payload('data entry must be an object') unless entry.is_a?(Hash)
      odds = entry.key?('odds')
      fixture = odds ? entry : entry['fixture']
      fail_payload('fixture must be an object') unless fixture.is_a?(Hash)
      %w[id game_id start_date status].each do |key|
        fail_payload("fixture #{key} missing") unless fixture[key].is_a?(String) && fixture[key].present?
      end
      begin
        Time.iso8601(fixture['start_date'])
      rescue ArgumentError
        fail_payload('fixture start_date must be ISO 8601')
      end
      teams = %w[home away].to_h do |side|
        competitors = fixture["#{side}_competitors"]
        fail_payload("#{side} competitors must contain exactly one team") unless
          competitors.is_a?(Array) && competitors.length == 1 && competitors.first.is_a?(Hash)
        team = competitors.first
        fail_payload("#{side} team id/name missing") unless team['id'].is_a?(String) &&
          team['id'].present? && team['name'].is_a?(String) && team['name'].present?
        [side, team]
      end
      fail_payload('home and away have same team ID') if teams['home']['id'] == teams['away']['id']
      fail_payload('not an MLB fixture') unless (odds ? entry['league'] : entry['league']).is_a?(Hash) &&
        entry['league']['id'].to_s.downcase == 'mlb'
      fail_payload('not a baseball fixture') unless entry['sport'].is_a?(Hash) &&
        entry['sport']['id'].to_s.downcase == 'baseball'

      kind = if odds
        fail_payload('odds must be an array') unless entry['odds'].is_a?(Array)
        'odds'
      elsif entry['results'].is_a?(Array) && entry['stats'].nil?
        'player_results'
      elsif entry['stats'].is_a?(Hash) && entry['results'].nil?
        'team_results'
      else
        fail_payload('expected odds, player results or team results')
      end
      fail_payload('odds fixture cannot contain results') if odds && (entry.key?('results') || entry.key?('stats'))

      players = []
      team_stats = {}
      if kind == 'player_results'
        fail_payload('empty player results') if entry['results'].empty?
        players = entry['results'].map do |result|
          fail_payload('invalid player result') unless result.is_a?(Hash) &&
            result['player'].is_a?(Hash) && result['team'].is_a?(Hash)
          player = result['player']
          fail_payload('player id/name/position missing') unless %w[id name position].all? { |k| player[k].is_a?(String) && player[k].present? }
          team_id = result['team']['id']
          fail_payload('player team not in fixture') unless teams.values.any? { |team| team['id'] == team_id && team['name'] == result['team']['name'] }
          fail_payload('player status missing') unless result['status'].is_a?(String) && result['status'].present?
          periods = validate_periods(result['stats'])
          {
            'id' => player['id'], 'name' => player['name'], 'position' => player['position'],
            'team_id' => team_id, 'status' => result['status'], 'periods' => periods,
            'scoring' => scoring(periods, player['position'])
          }
        end
        fail_payload('duplicate player ID') unless players.map { |p| p['id'] }.uniq.length == players.length
      elsif kind == 'team_results'
        %w[home away].each do |side|
          team_stats[side] = validate_periods(entry['stats'][side])
        end
      else
        entry['odds'].each do |market|
          fail_payload('invalid odds market') unless market.is_a?(Hash) &&
            %w[id sportsbook market name].all? { |key| market[key].is_a?(String) && market[key].present? }
          fail_payload('odds market belongs to a different game') unless market['id'].start_with?("#{fixture['game_id']}:")
          if market['team_id']
            fail_payload('odds team not in fixture') unless teams.values.any? { |team| team['id'] == market['team_id'] }
          end
        end
      end
      {
        'source' => source, 'kind' => kind, 'fixture_id' => fixture['id'],
        'game_id' => fixture['game_id'], 'start_date' => fixture['start_date'],
        'status' => fixture['status'], 'completed' => fixture['status'] == 'completed',
        'historical' => true, 'teams' => teams, 'players' => players,
        'team_stats' => team_stats, 'scores' => kind == 'team_results' ? entry['scores'] : nil,
        'in_play' => kind == 'team_results' ? entry['in_play'] : nil,
        'odds' => kind == 'odds' ? entry['odds'] : []
      }
    rescue JSON::ParserError => e
      raise InvalidPayload, "Invalid JSON: #{e.message}"
    end

    def self.scoring(periods, position)
      all = periods.find { |period| period['period'] == 'all' }
      stats = all ? all['stats'] : {}
      pitcher = %w[SP RP CP P].include?(position)
      mapping = pitcher ? PITCHER : BATTER
      mapped = mapping.each_with_object({}) do |(name, id), output|
        output[id] = stats[name] if stats.key?(name) && !stats[name].nil?
      end
      unless pitcher
        components = %w[hits doubles triples home_runs]
        if components.all? { |name| stats.key?(name) && !stats[name].nil? }
          singles = stats['hits'] - stats['doubles'] - stats['triples'] - stats['home_runs']
          fail_payload('negative derived singles') if singles.negative?
          mapped[Mlb::Stats::SINGLES.id] = singles
        end
      end
      ids = (pitcher ? Mlb::ScoringMap::MAPPING.merge(Mlb::ScoringMap::PITCHER_OVERRIDE_MAPPING) : Mlb::ScoringMap::MAPPING).keys.map(&:id)
      { 'stat_ids' => mapped, 'missing_stat_ids' => ids - mapped.keys }
    end

    def self.validate_periods(periods)
      fail_payload('stats must be an array of periods') unless periods.is_a?(Array)
      periods.each do |period|
        fail_payload('invalid stats period') unless period.is_a?(Hash) &&
          period['period'].is_a?(String) && period['period'].present? && period['stats'].is_a?(Hash)
        fail_payload('stats must be numeric or null') unless period['stats'].values.all? { |v| v.nil? || v.is_a?(Numeric) }
      end
      fail_payload('duplicate stats period') unless periods.map { |p| p['period'] }.uniq.length == periods.length
      periods
    end

    def self.fail_payload(message)
      raise InvalidPayload, message
    end
    private_class_method :validate_periods, :fail_payload, :scoring
  end
end