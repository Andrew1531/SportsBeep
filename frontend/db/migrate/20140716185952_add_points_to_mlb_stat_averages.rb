class AddPointsToMlbStatAverages < ActiveRecord::Migration[4.2]
  def change
    add_column :mlb_stat_averages, :points, :float
  end
end
