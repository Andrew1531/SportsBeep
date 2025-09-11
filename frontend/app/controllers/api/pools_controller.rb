class Api::PoolsController < Api::BaseController

  def index
    @game = Game.find params[:game_id]
    @pools = @game.pools
    respond_with @pools
  end

end
