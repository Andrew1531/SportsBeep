class Nfl::Game < Game

  def players
    Nfl::Player.where(team: teams)
  end

  def teams
    [home_team, away_team]
  end

  private

    def enqueue_game_import_worker
      # Background.schedule Mlb::LineupWorker, (start_time - 1.hour), id
      Background.schedule Nfl::GameStatsWorker, start_time, id
    end

end
