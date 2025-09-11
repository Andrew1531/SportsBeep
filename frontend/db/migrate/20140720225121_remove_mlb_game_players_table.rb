class RemoveMlbGamePlayersTable < ActiveRecord::Migration
  def change
    drop_table :mlb_game_players
  end
end
