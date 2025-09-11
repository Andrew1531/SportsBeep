class Nfl::StandingsImportWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable
  include SportsData::Nfl::Client

  recurrence { hourly.minute_of_hour(30) }

  def perform
    data = get("teams/#{year}/#{season}/standings.json")
    data['conferences'].each do |conference|
      conference['divisions'].each do |division|
        division['teams'].each do |t|
          team = Nfl::Team.find_by external_id: t['id']
          team.stats.store Nfl::Stats::WINS, t['overall']['wins']
          team.stats.store Nfl::Stats::LOSSES, t['overall']['losses']
          team.stats.store Nfl::Stats::GAMES, t['overall']['wins'] + t['overall']['losses']
        end
      end
    end
  end

end