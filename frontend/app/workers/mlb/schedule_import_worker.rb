class Mlb::ScheduleImportWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable
  include SportsData::Mlb::Client

  recurrence { daily.hour_of_day(12) }

  def perform
    teams = Mlb::Team.all
    year  = Time.now.year
    get("schedule/#{year}.xml").each('calendars event') do |xml|
      game = Mlb::Game.find_or_initialize_by external_id: xml['id']
      game.home_team  = Mlb::Team.find_by external_id: xml['home']
      game.away_team  = Mlb::Team.find_by external_id: xml['visitor']
      game.start_time = xml.text 'scheduled_start'
      game.status = nil if xml['status'] == 'scheduled'
      game.save
    end
  end

end