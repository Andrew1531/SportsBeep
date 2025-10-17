class ChangeMlbPlayersBattingAndThrowingEnumsToStrings < ActiveRecord::Migration[4.2]
  def change
    change_column :mlb_players, :bats, :string
    change_column :mlb_players, :throws, :string
  end
end
