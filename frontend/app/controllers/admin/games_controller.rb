class Admin::GamesController < Admin::BaseController

  before_action :set_game, except: :index

  def show
  end

  def update
    @game.attributes = permitted_params
    BettableGame.new(@game).call if game_was_just_made_bettable?(@game)
    @game.save
    respond_with @game
  end

  private

    def set_game
      @game = Game.find params[:id]
    end

    def permitted_params
      params.require(:game).permit(:bettable)
    end

    def game_was_just_made_bettable?(game)
      game.bettable_changed? && game.bettable?
    end

end
