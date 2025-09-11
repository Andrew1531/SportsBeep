class Nfl::GameStatsWorker < GameStatsWorker
  include SportsData::Nfl::Client

  def perform(game_id)
    @game = Nfl::Game.find(game_id)
    @players = Set.new
    @data = get("#{year}/#{season}/#{@game.week}/#{@game.away_team.abbr}/#{@game.home_team.abbr}/statistics.json")
    @game.update(status: :live) unless @game.status?(:live)

    %w(home_team away_team).each do |t|
      json = @data[t]
      @statistics = json['statistics']
      @team = Nfl::Team.find_by abbr: json['id']
      parse_and_store_player_data
      parse_and_store_team_data(json)
    end

    requeue_or_end_game
  end

  private

    def parse_and_store_player_data
      parse('touchdowns')  { |stats, json| SportsData::Nfl::Parsers::TouchdownParser.new(json, stats).parse }
      parse('passing')     { |stats, json| SportsData::Nfl::Parsers::PassingParser.new(json, stats).parse }
      parse('rushing')     { |stats, json| SportsData::Nfl::Parsers::RushingParser.new(json, stats).parse }
      parse('receiving')   { |stats, json| SportsData::Nfl::Parsers::ReceivingParser.new(json, stats).parse }
      parse('punt_return') { |stats, json| SportsData::Nfl::Parsers::PuntReturnParser.new(json, stats).parse }
      parse('kick_return') { |stats, json| SportsData::Nfl::Parsers::KickReturnParser.new(json, stats).parse }
      parse('fumbles')     { |stats, json| SportsData::Nfl::Parsers::FumbleParser.new(json, stats).parse }
      parse('defense')     { |stats, json| SportsData::Nfl::Parsers::DefenseParser.new(json, stats).parse }
      parse('extra_point') { |stats, json| SportsData::Nfl::Parsers::ExtraPointParser.new(json, stats).parse }
      parse('kickoffs')    { |stats, json| SportsData::Nfl::Parsers::KickoffParser.new(json, stats).parse }
      parse('field_goal')  { |stats, json| SportsData::Nfl::Parsers::FieldGoalParser.new(json, stats).parse }
      parse('two_point_conversion') { |stats, json| SportsData::Nfl::Parsers::TwoPtConversionParser.new(json, stats).parse }
    end

    def parse_and_store_team_data(team_json)
      return unless @statistics
      @team.game_stats.with_options(game: @game) do |stats|
        stats.store Nfl::Stats::TURNOVERS, @statistics.drill('passing.team.int') + @statistics.drill('fumbles.team.lost')
        stats.store Nfl::Stats::PENALTIES, @statistics.drill('penalty.team.num')
        stats.store Nfl::Stats::PENALTY_YDS, @statistics.drill('penalty.team.yds')
        stats.store Nfl::Stats::RED_ZONE_PCT, @statistics.drill('redzone_efficiency.team.pct')
        stats.store Nfl::Stats::THIRD_DOWN_CV, @statistics.drill('third_down_efficiency.team.conv')
        stats.store Nfl::Stats::FOURTH_DOWN_CV, @statistics.drill('fourth_down_efficiency.team.conv')
        stats.store Nfl::Stats::TOTAL_YDS, @statistics.drill('rushing.team.yds') + @statistics.drill('passing.team.yds')
        stats.store Nfl::Stats::FIRST_DOWNS, @statistics.drill('first_downs.team.num')
        stats.store Nfl::Stats::CHALLENGES, (2 - team_json['remaining_challenges'])
      end
    end

    def parse(key, &block)
      return unless @statistics && @statistics.key?(key)
      @statistics[key].fetch('players', []).each do |json|
        next unless player = Nfl::Player.find_by(external_id: json['id'])
        @players << player
        player.stats.with_options(game: @game, team: @team) do |stats|
          yield stats, json
        end
      end
    end

    def status
      @_status ||= @data['status']
    end

end