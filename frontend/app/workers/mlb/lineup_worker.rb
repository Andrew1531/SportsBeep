class Mlb::LineupWorker
  include Sidekiq::Worker
  include SportsData::Mlb::Client

  def perform(game_id)
    @game = Mlb::Game.find(game_id)
    @data = get("event/#{@game.external_id}.xml")
    update_lineup('home')
    update_lineup('visitor')
    requeue if @game.future?
  end

  def update_lineup(team)
    @data.each("game #{team} lineup player") do |xml|
      player = Mlb::Player.find_by(external_id: xml['id'])
      if player
        lineup = Mlb::LineupPosition.find_by(player: player, game: @game) || Mlb::LineupPosition.new(player: player, game: @game)
        lineup.position = xml['pos']
        # notify_users_about_position_change(player) if position_changed?(player, lineup)
        lineup.save!
      else
        Background.push Mlb::RosterImportWorker
      end
    end
  end

  private

    def requeue
      if ENV['LINEUP_POLLING_INTERVAL']
        seconds = ENV['LINEUP_POLLING_INTERVAL'].to_i
        seconds = rand (seconds - 5)..(seconds + 5)
        self.class.perform_in seconds, @game.id unless Rails.env.development?
      end
    end

    def position_changed?(player, lineup)
      (player.position != lineup.position) && (lineup.new_record? || lineup.position_changed?)
    end

    def notify_users_about_position_change(player)
      Mlb::Ticket.requires_status_updates_for(player).each do |ticket|
        Push::PlayerPositionUpdate.new(player, ticket).send_to(ticket.user, background: true)
      end
    end

end