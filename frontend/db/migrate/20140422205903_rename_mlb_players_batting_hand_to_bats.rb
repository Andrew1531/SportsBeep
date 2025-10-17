class RenameMlbPlayersBattingHandToBats < ActiveRecord::Migration[4.2]
  def change
    rename_column :mlb_players, :batting_hand, :bats
  end
end
