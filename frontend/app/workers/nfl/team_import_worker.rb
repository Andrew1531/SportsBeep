class Nfl::TeamImportWorker
  include Sidekiq::Worker
  include SportsData::Nfl::Client

  def perform
    get('teams/hierarchy.json') do |json|
      json['conferences'].each do |conference|
        conference['divisions'].each do |division|
          division['teams'].each do |t|
            team = Nfl::Team.find_or_initialize_by external_id: t['id']
            team.abbr = t['id']
            team.name = t['name']
            team.market = t['market']
            team.league = json['league']
            team.division = division['name']
            team.conference = conference['name']
            team.save!
          end
        end
      end
    end
  end

end