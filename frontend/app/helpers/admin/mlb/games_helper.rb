module Admin::Mlb::GamesHelper

  def matchup(game)
    "#{game.away_team} @ #{game.home_team}"
  end

end
