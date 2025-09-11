class Api::PlayersController < Api::BaseController

  before_action :set_game, only: [:index, :previous]
  before_action :set_ticket, only: :index

  def index
    scope = @game || @ticket
    @players = scope.players.includes [:team, :lineup_positions, :seasonal_stats, :recent_stats]
    if @game && @game.has_official_lineup?
      @players = @players.on_official_lineup_for_game(@game)
    elsif @game
      @players = @players.on_current_roster
    end

    if @ticket
      @game ||= @ticket.game
      @squads = @ticket.ticket_squads
    end

    respond_with @players || Player.none
  end

  def previous
    @games = @game.teams.map do |team|
      team.games.before(@game.start_time).order(start_time: :desc).first
    end
    @players = Player.joins(stats: :game).where(stats: { game_id: @games }).uniq
    render :index
  end

  def show
    @player = Player.find(params[:id])
    respond_with @player
  end

  private

    def set_game
      @game = Game.find_by id: params[:game_id]
    end

    def set_ticket
      @ticket = Ticket.find_by id: params[:ticket_id]
    end

end


