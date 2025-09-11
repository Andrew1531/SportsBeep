class AddStatToStats < ActiveRecord::Migration
  def change
    add_column :stats, :stat, :integer
    add_column :team_stats, :stat, :integer
    add_column :seasonal_stats, :stat, :integer
    add_column :recent_stats, :stat, :integer
  end
end
