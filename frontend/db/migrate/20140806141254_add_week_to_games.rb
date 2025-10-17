class AddWeekToGames < ActiveRecord::Migration[4.2]
  def change
    add_column :games, :week, :integer
  end
end
