class Mlb::TeamStatsWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable
  include SportsData::Mlb::Client

  recurrence { daily.hour_of_day(12) }

  def perform
    teams = Mlb::Team.all
    year  = Time.now.year
    get("seasontd/teams/#{year}.xml").each('statistics team') do |xml|
      team = Mlb::Team.find_by external_id: xml['id']
      logger.info "Updating team: #{team} home runs"
      with_options(season: year) do
        team.stats.store Mlb::Stats::HOME_RUNS, xml['hitting onbase hr']
        team.stats.store Mlb::Stats::WINS, xml['pitching games win']
        team.stats.store Mlb::Stats::LOSSES, xml['pitching games loss']
        team.stats.store Mlb::Stats::RUNS, xml['hitting runs earned']
        team.stats.store Mlb::Stats::BATTING_AVERAGE, xml['hitting avg']
        team.stats.store Mlb::Stats::ON_BASE_PCT, xml['hitting obp']
        team.stats.store Mlb::Stats::SLUGGING_PCT, xml['hitting slg']
      end
    end
  end

end