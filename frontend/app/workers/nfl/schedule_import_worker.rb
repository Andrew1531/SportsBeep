class Nfl::ScheduleImportWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable
  include SportsData::Nfl::Client

  recurrence { daily.hour_of_day(12) }

  def perform
    get("#{year}/#{season}/schedule.json") do |json|
      json['weeks'].each do |w|
        w['games'].each do |g|
          game = Nfl::Game.find_or_initialize_by external_id: g['id']
          game.home_team  = Nfl::Team.find_by external_id: g['home']
          game.away_team  = Nfl::Team.find_by external_id: g['away']
          game.start_time = g['scheduled']
          game.week = w['number']
          game.save!
        end
      end
    end
  end

end