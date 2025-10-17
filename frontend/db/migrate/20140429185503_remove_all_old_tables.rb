class RemoveAllOldTables < ActiveRecord::Migration[4.2]
  def change
    drop! :baseball_games
    drop! :baseball_games_hitting_player_stat_lines
    drop! :baseball_games_pitching_player_stat_lines
    drop! :baseball_games_pitching_team_stat_lines
    drop! :baseball_h2_h_tickets
    drop! :baseball_hitting_base_stat_lines
    drop! :baseball_on_base_base_stat_lines
    drop! :baseball_outcome_base_stat_lines
    drop! :baseball_outs_base_stat_lines
    drop! :baseball_pitching_base_stat_lines
    drop! :baseball_player_game_performances
    drop! :baseball_player_season_performances
    drop! :baseball_players
    drop! :baseball_runs_base_stat_lines
    drop! :baseball_seasons
    drop! :baseball_steals_base_state_lines
    drop! :baseball_team_game_performances
    drop! :baseball_team_season_performances
    drop! :baseball_teams
    drop! :basketball_base_stat_lines
    drop! :basketball_games
    drop! :basketball_player_game_performances
    drop! :basketball_player_season_performances
    drop! :basketball_players
    drop! :basketball_seasons
    drop! :basketball_supplemental_player_stat_lines
    drop! :basketball_supplemental_team_stat_lines
    drop! :basketball_team_game_performances
    drop! :basketball_team_season_performances
    drop! :basketball_teams
    drop! :betting_groups
    drop! :bust_questions
    drop! :football_defense_stat_lines
    drop! :football_extra_point_stat_lines
    drop! :football_field_goal_return_stat_lines
    drop! :football_field_goal_stat_lines
    drop! :football_first_down_stat_lines
    drop! :football_fourth_down_efficiency_stat_lines
    drop! :football_fumble_stat_lines
    drop! :football_games
    drop! :football_goal_line_efficiency_stat_lines
    drop! :football_kick_return_stat_lines
    drop! :football_kickoff_stat_lines
    drop! :football_passing_stat_lines
    drop! :football_penalty_stat_lines
    drop! :football_player_game_performances
    drop! :football_player_season_performances
    drop! :football_players
    drop! :football_punt_return_stat_lines
    drop! :football_punting_stat_lines
    drop! :football_receiving_stat_lines
    drop! :football_red_zone_efficiency_stat_lines
    drop! :football_rushing_stat_lines
    drop! :football_seasons
    drop! :football_team_game_performances
    drop! :football_team_season_performances
    drop! :football_teams
    drop! :football_third_down_efficiency_stat_lines
    drop! :football_touchdown_stat_lines
    drop! :football_two_point_conversion_stat_lines
    drop! :game_polling_tasks
    drop! :hockey_games
    drop! :hockey_player_game_performances
    drop! :hockey_player_season_performances
    drop! :hockey_players
    drop! :hockey_seasons
    drop! :hockey_team_game_performances
    drop! :hockey_team_season_performances
    drop! :hockey_teams
  end

  private

    def drop!(table_name)
      drop_table table_name if self.table_exists?(table_name.to_s)
    end

end
