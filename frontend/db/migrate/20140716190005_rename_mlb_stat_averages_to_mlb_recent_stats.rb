class RenameMlbStatAveragesToMlbRecentStats < ActiveRecord::Migration
  def change
    rename_table :mlb_stat_averages, :mlb_recent_stats
  end
end
