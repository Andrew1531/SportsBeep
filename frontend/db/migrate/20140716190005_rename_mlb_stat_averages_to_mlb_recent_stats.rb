class RenameMlbStatAveragesToMlbRecentStats < ActiveRecord::Migration[4.2]
  def change
    rename_table :mlb_stat_averages, :mlb_recent_stats
  end
end
