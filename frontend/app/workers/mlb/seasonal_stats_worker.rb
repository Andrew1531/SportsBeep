class Mlb::SeasonalStatsWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable
  include SportsData::Mlb::Client

  attr_reader :xml, :stats
  recurrence { daily.hour_of_day(12) }

  def perform
    year = Time.now.year
    get("seasontd/players/#{year}.xml").each('statistics player') do |xml|
      player = Mlb::Player.find_by external_id: xml['id']
      parse(xml, player) if player.present?
    end
  end

  private

    def parse(xml, player)
      @xml = xml
      @stats = player.seasonal_stats
      if player.pitcher?
        parse_pitching
      else
        parse_hitting
      end
    end

    def parse_pitching
      stats.store Mlb::Stats::WINS, xml['team pitching games win']
      stats.store Mlb::Stats::LOSSES, xml['team pitching games loss']
      stats.store Mlb::Stats::SAVES, xml['team pitching games save']
      stats.store Mlb::Stats::ERA, xml['team pitching era']
      stats.store Mlb::Stats::STRIKE_OUTS, xml['team pitching outs ktotal']
      stats.store Mlb::Stats::WALKS, xml['team pitching onbase bb']
      stats.store Mlb::Stats::STARTS, xml['team pitching games start']
      stats.store Mlb::Stats::INNINGS_PITCHED, xml['team pitching ip_2']
      stats.store Mlb::Stats::HITS_ALLOWED, xml['team pitching onbase h']
      stats.store Mlb::Stats::RUNS_ALLOWED, xml['team pitching runs total']
      stats.store Mlb::Stats::HOME_RUNS, xml['team pitching onbase hr']
      stats.store Mlb::Stats::WHIP, xml['team pitching whip']
      stats.store Mlb::Stats::ON_BASE_AVERAGE, xml['team pitching oba']
    end

    def parse_hitting
      stats.store Mlb::Stats::AT_BATS, xml['team hitting ab']
      stats.store Mlb::Stats::BATTING_AVERAGE, xml['team hitting avg']
      stats.store Mlb::Stats::WALKS, xml['team hitting onbase bb']
      stats.store Mlb::Stats::STRIKE_OUTS, xml['team hitting outs ktotal']
      stats.store Mlb::Stats::DOUBLES, xml['team hitting onbase d']
      stats.store Mlb::Stats::HIT_BY_PITCH, xml['team hitting onbase hbp']
      stats.store Mlb::Stats::HOME_RUNS, xml['team hitting onbase hr']
      stats.store Mlb::Stats::ON_BASE_PCT, xml['team hitting obp']
      stats.store Mlb::Stats::RBIS, xml['team hitting rbi']
      stats.store Mlb::Stats::SINGLES, xml['team hitting onbase s']
      stats.store Mlb::Stats::STOLEN_BASES, xml['team hitting steal stolen']
      stats.store Mlb::Stats::SLUGGING_PCT, xml['team hitting slg']
      stats.store Mlb::Stats::TRIPLES, xml['team hitting onbase t']
    end

end