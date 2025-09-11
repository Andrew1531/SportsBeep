class Mlb::TeamImportWorker
  include Sidekiq::Worker
  include SportsData::Mlb::Client

  def perform(year: nil)
    year ||= Time.now.year
    get("teams/#{year}.xml").each('teams team') do |xml|
      team = Mlb::Team.find_or_initialize_by external_id: xml['id']
      team.abbr     = xml['abbr']
      team.name     = xml['name']
      team.market   = xml['market']
      team.league   = xml['league']
      team.division = xml['division']
      team.save!
    end
  end

end