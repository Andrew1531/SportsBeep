class Mlb::GameStatsWorker < GameStatsWorker
  include SportsData::Mlb::Client

  def perform(game_id)
    @players = Set.new
    @game = Mlb::Game.find(game_id)
    @data = get("statistics/#{@game.external_id}.xml")
    @game.update(status: :live) unless @game.status?(:live)
    parse_and_store_data
    requeue_or_end_game
  end

  private

    def parse_and_store_data
      ['home', 'visitor'].each do |t|
        team = Mlb::Team.find_by external_id: @data["statistics #{t} id"]
        parse_and_store_hitting  "statistics #{t} hitting players player",  team
        parse_and_store_pitching "statistics #{t} pitching players player", team
        parse_and_store_fielding "statistics #{t} fielding players player", team
      end
    end

    def parse_and_store_hitting(path, team)
      @data.each(path) do |xml|
        player = Mlb::Player.find_by external_id: xml['id']
        return unless player
        @players << player
        player.stats.with_options(game: @game, team: team) do |stats|
          stats.store Mlb::Stats::AT_BATS, xml['ab']
          stats.store Mlb::Stats::BATTING_AVERAGE, xml['avg']
          stats.store Mlb::Stats::SINGLES, xml['onbase s']
          stats.store Mlb::Stats::DOUBLES, xml['onbase d']
          stats.store Mlb::Stats::TRIPLES, xml['onbase t']
          stats.store Mlb::Stats::HOME_RUNS, xml['onbase hr']
          stats.store Mlb::Stats::HITS, xml['onbase h']
          stats.store Mlb::Stats::STRIKE_OUTS, xml['outs ktotal']
          stats.store Mlb::Stats::ON_BASE_PCT, xml['obp']
          stats.store Mlb::Stats::SLUGGING_PCT, xml['slg']
          stats.store Mlb::Stats::RUNS, xml['runs total']
          stats.store Mlb::Stats::RBIS, xml['rbi']
          stats.store Mlb::Stats::WALKS, xml['onbase bb']
          stats.store Mlb::Stats::HIT_BY_PITCH, xml['onbase hbp']
          stats.store Mlb::Stats::STOLEN_BASES, xml['steal stolen']
          stats.store Mlb::Stats::OUTS, sum_outs(xml['outs'])
        end
      end
    end

    def parse_and_store_pitching(path, team)
      @data.each(path) do |xml|
        player = Mlb::Player.find_by external_id: xml['id']
        return unless player
        @players << player
        player.stats.with_options(game: @game, team: team) do |stats|
          stats.store Mlb::Stats::WINS, xml['games win']
          stats.store Mlb::Stats::LOSSES, xml['games loss']
          stats.store Mlb::Stats::SAVES, xml['games save']
          stats.store Mlb::Stats::STARTS, xml['games start']
          stats.store Mlb::Stats::ERA, xml['era']
          stats.store Mlb::Stats::INNINGS_PITCHED, xml['ip_2']
          stats.store Mlb::Stats::STRIKE_OUTS, xml['outs ktotal']
          stats.store Mlb::Stats::RUNS_ALLOWED, xml['runs total']
          stats.store Mlb::Stats::HITS_ALLOWED, xml['onbase h']
          stats.store Mlb::Stats::HOME_RUNS_ALLOWED, xml['onbase hr']
          stats.store Mlb::Stats::WALKS, xml['onbase bb']
          stats.store Mlb::Stats::HIT_BATTER, xml['onbase hbp']
          stats.store Mlb::Stats::WHIP, xml['whip']
          stats.store Mlb::Stats::ON_BASE_AVERAGE, xml['oba']
        end
      end
    end

    def parse_and_store_fielding(path, team)
      @data.each(path) do |xml|
        player = Mlb::Player.find_by external_id: xml['id']
        next unless player
        @players << player
        player.stats.with_options(game: @game, team: team) do |stats|
          stats.store Mlb::Stats::ERRORS, xml['error']
        end
      end
    end

    def sum_outs(element)
      attrs = %w(ktotal po fo fidp go gidp lo lidp sacfly sachit)
      attrs.sum { |attr| element[attr].to_i }
    end

    def status
      @_status ||= @data['statistics status']
    end

end