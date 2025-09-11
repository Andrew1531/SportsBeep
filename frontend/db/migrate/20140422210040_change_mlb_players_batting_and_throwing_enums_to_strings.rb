class ChangeMlbPlayersBattingAndThrowingEnumsToStrings < ActiveRecord::Migration
  def change
    change_column :mlb_players, :bats, :string
    change_column :mlb_players, :throws, :string
  end
end
