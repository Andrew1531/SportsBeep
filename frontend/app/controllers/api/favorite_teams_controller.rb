class Api::FavoriteTeamsController < Api::BaseController

  def update
    @favorite_team = current_user.favorite_team
    @favorite_team.update baseball: Mlb::Team.find(permitted_params[:baseball])
    respond_with @favorite_team
  end

  private

    def permitted_params
      params.require(:favorite_team).permit(:baseball)
    end

end
