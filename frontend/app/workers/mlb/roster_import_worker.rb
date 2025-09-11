class Mlb::RosterImportWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable
  include SportsData::Mlb::Client

  recurrence { hourly.minute_of_hour(30) }

  def perform
    year = Time.now.year
    ids = []
    get("rosters/#{year}.xml").each('rosters team') do |xml|
      team = Mlb::Team.find_by external_id: xml['id']
      xml.each('players player') do |p|
        player = Mlb::Player.find_or_initialize_by external_id: p['id']
        ids << p['id']
        player.team = team
        player.number = p['jersey']
        player.position = p['primary_position']
        player.first_name = p['preferred_name']
        player.last_name = p['last_name']
        player.bats = p['bat_hand']
        player.throws = p['throw_hand']
        player.status = p['status']
        player.on_current_roster = true
        notify_users_of_injury(player) if player.just_injured?
        player.save!
      end
    end

    Mlb::Player.find_each do |player|
      player.update on_current_roster: false if !player.external_id.in?(ids)
    end

  end

  private

    def notify_users_of_injury(player)
      logger.info "Notifying users of #{player.name}'s injury"
      Mlb::Ticket.requires_status_updates_for(player).each do |ticket|
        Push::PlayerInjury.new(player, ticket).send_to(ticket.user, background: true)
      end
    end

end