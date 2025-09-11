namespace :sportsdata do

  desc "Run all import workers"
  task sync: :environment do
    [
      Mlb::RosterImportWorker,
      Mlb::ScheduleImportWorker,
      Mlb::StandingsImportWorker,
      Mlb::TeamImportWorker,
      Mlb::TeamStatsWorker
    ].each do |worker|
      puts "Queueing #{worker.name}"
      Background.push worker
    end
  end

end