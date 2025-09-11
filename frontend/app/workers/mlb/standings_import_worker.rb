class Mlb::StandingsImportWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable
  include SportsData::Mlb::Client

  recurrence { daily.hour_of_day(12) }

  def perform
    teams = Mlb::Team.all
    year  = Time.now.year
    get("standings/#{year}.xml").each('standings league division team') do |xml|
      team = Mlb::Team.find_by external_id: xml['id']
      team.stats.store Mlb::Stats::GAMES, xml['win'].to_i + xml['loss'].to_i
    end
  end

end