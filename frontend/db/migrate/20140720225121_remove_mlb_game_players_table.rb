class RemoveMlbGamePlayersTable < ActiveRecord::Migration[4.2]
  def change
    drop_table :mlb_game_players
  end
end
