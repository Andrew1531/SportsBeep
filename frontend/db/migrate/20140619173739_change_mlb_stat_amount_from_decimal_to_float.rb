class ChangeMlbStatAmountFromDecimalToFloat < ActiveRecord::Migration
  def change
    change_column :mlb_stats, :amount, :float
    change_column :mlb_stat_averages, :amount, :float
    change_column :mlb_seasonal_stats, :amount, :float
  end
end
