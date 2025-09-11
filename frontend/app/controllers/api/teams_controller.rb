class Api::TeamsController < Api::BaseController

  def index
    @teams = _sport(Team).standard.all.includes(:stats)
    respond_with @teams
  end

  def rankings
    @team = Team.find params[:id]
    @rankings = @team.rankings
  end

end
