class AddPointsToMlbStatAverages < ActiveRecord::Migration
  def change
    add_column :mlb_stat_averages, :points, :float
  end
end
