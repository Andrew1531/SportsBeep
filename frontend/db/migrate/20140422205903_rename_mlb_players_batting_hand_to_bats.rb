class RenameMlbPlayersBattingHandToBats < ActiveRecord::Migration
  def change
    rename_column :mlb_players, :batting_hand, :bats
  end
end
