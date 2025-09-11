class RenameMlbPlayersThrowingHandToThrows < ActiveRecord::Migration
  def change
    rename_column :mlb_players, :throwing_hand, :throws
  end
end
