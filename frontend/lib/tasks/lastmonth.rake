namespace :mlb do
  desc "Pull down all of the stats from last month again"
  task lastmonth: :environment do
    Mlb::Game.past(1.month).each do |game|
      Background.push Mlb::GameStatsWorker, game.id
    end
  end
end

namespace :nfl do
  namespace :stats do
    desc 'Pull down all of the stats for games that happened already'
    task rerun: :environment do
      Nfl::Game.past.where(status: 'ended').each do |game|
        Background.push Nfl::GameStatsWorker, game.id
      end

      Background.push Nfl::StandingsImportWorker
      Background.push Nfl::SeasonalStatsWorker
    end
  end
end