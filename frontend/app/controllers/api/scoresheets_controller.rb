class Api::ScoresheetsController < Api::BaseController

  before_action :set_player
  before_action :set_ticket

  def show
    @stats = @player.stats.scored(current_sport).where(game: @ticket.game)
  end

  private

    def set_ticket
      @ticket = Ticket.find_by id: params[:ticket_id]
    end

    def set_player
      @player = Player.find_by id: params[:player_id]
    end

end
