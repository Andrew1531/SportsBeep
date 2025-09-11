class PostponeGame

  def initialize(game)
    @game = game
    @game.status = :postponed
    @game.bettable = false
    @game.game_league_picks.destroy_all
  end

  def call
    @game.save
  end

end