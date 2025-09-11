class Api::GamesController < Api::BaseController

  def index
    days = (params[:days] || default_days).to_i
    @games = _sport(Game).bettable.between(Time.current, days.days.from_now).eligible.
              includes(home_team: :stats).includes(away_team: :stats)
    respond_with @games
  end

  def show
    @game = Game.find(params[:id])
    respond_with @game
  end

  private

    def default_days
      7
    end

end
