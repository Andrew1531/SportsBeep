class Admin::Nfl::GamesController < Admin::GamesController

  def index
    @games = ::Nfl::Game.between(Time.now, 20.years.from_now).includes(:home_team, :away_team).page params[:page]
    @sport = 'nfl'
    render 'admin/games/index'
  end

end
