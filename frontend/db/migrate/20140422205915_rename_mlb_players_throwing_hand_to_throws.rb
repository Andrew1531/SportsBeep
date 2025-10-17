class RenameMlbPlayersThrowingHandToThrows < ActiveRecord::Migration[4.2]
  def change
    rename_column :mlb_players, :throwing_hand, :throws
  end
end
