class RenameLineupPlayersToLineupPositions < ActiveRecord::Migration
  def change
    rename_table :lineup_players, :lineup_positions
  end
end
