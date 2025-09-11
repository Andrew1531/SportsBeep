class Nfl::RosterImportWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable
  include SportsData::Nfl::Client

  recurrence { daily.hour_of_day(12) }

  def perform
    teams = Nfl::Team.all
    ids = []
    teams.each do |team|
      get("teams/#{team.external_id}/roster.json") do |json|
        json['players'].each do |p|
          player = Nfl::Player.find_or_initialize_by external_id: p['id']
          ids << p['id']
          player.team = team
          player.number = p['jersey_number']
          player.position = p['position']
          player.first_name = p['name_first']
          player.last_name = p['name_last']
          player.status = p['status']
          player.on_current_roster = true
          # notify_users_of_injury(player) if player.just_injured?
          player.save!
        end
      end
    end
    Nfl::Player.where.not(external_id: ids).update_all(on_current_roster: false)
  end

  private

    def notify_users_of_injury(player)
      logger.info "Notifying users of #{player.name}'s injury"
      Nfl::Ticket.requires_status_updates_for(player).each do |ticket|
        Push::PlayerInjury.new(player, ticket).send_to(ticket.user, background: true)
      end
    end

end