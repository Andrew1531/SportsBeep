class Api::LeaguePicksController < Api::BaseController

  def index
    @game = Game.find params[:game_id]
    @league_picks = @game.league_picks.order(:start_time).includes(home_team: :stats).includes(away_team: :stats)
    respond_with @league_picks
  end

end
