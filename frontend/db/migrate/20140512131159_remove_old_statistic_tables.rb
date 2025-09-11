class RemoveOldStatisticTables < ActiveRecord::Migration
  def change
    drop_table :mlb_pitching_stat_lines  if self.table_exists?(:mlb_pitching_stat_lines.to_s)
    drop_table :mlb_hitting_stat_lines   if self.table_exists?(:mlb_hitting_stat_lines.to_s)
    drop_table :mlb_pitching_scoresheets if self.table_exists?(:mlb_pitching_scoresheets.to_s)
    drop_table :mlb_hitting_scoresheets  if self.table_exists?(:mlb_hitting_scoresheets.to_s)
  end
end
