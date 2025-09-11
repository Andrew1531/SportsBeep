class Admin::Mlb::GamesController < Admin::GamesController

  def index
    @games = ::Mlb::Game.between(Time.now, 20.years.from_now).includes(:home_team, :away_team).page params[:page]
    respond_with @games
  end

end
