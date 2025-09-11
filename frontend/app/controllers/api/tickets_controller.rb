class Api::TicketsController < Api::BaseController

  before_action :find_ticket, only: [:show, :update, :league_pick]

  def index
    @contest = Contest.find params[:contest_id]
    @tickets = @contest.tickets.sort_by(&:score).reverse
    respond_with @tickets
  end

  def create
    @ticket = _sport(Ticket).new(permitted_params)
    @ticket.game = Game.find params[:game_id]
    @ticket.pool = Pool.find params[:pool_id]
    @ticket.user = current_user
    @ticket.roster = _sport(TicketRoster).new @ticket, params[:ticket]
    @ticket.roster.save if @ticket.save
    respond_with @ticket
  end

  def show
    respond_with @ticket
  end

  def update
    update_attrs = permitted_params
    @ticket.roster = _sport(TicketRoster).new @ticket, params[:ticket]
    update_attrs.merge! player_ids: @ticket.roster.player_ids if @ticket.roster.players.size > 0
    if @ticket.update(update_attrs)
      @ticket.roster.save
    end
    respond_with @ticket
  end

  def league_pick
    @league_pick = @ticket.league_pick
    respond_with @league_pick
  end

  private

    def find_ticket
      @ticket = Ticket.find(params[:id])
    end

    def permitted_params
      params.require(:ticket).permit :league_pick_game_id, :league_pick_team_id
    end

end
