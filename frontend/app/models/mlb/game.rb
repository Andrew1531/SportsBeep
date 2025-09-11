class Mlb::Game < Game

  validate :must_have_standard_teams

  private

    def enqueue_game_import_worker
      Background.schedule Mlb::LineupWorker, (start_time - 12.hours), id
      Background.schedule Mlb::GameStatsWorker, start_time, id
    end

    def must_have_standard_teams
      standard = Mlb::Team.standard
      errors.add(:home_team, 'is non-standard') if home_team.name.in? Mlb::Team::NONSTANDARD_TEAMS
      errors.add(:away_team, 'is non-standard') if away_team.name.in? Mlb::Team::NONSTANDARD_TEAMS
    end

end
