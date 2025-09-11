class RemoveNflTables < ActiveRecord::Migration
  def change
    drop_table :nfl_games
    drop_table :nfl_game_pools
    drop_table :nfl_players
    drop_table :nfl_pools
    drop_table :nfl_teams
    drop_table :nfl_team_stats
  end
end
