class ChangeMlbStatsAmountFromIntegerToFloat < ActiveRecord::Migration[4.2]
  def up
   change_column :mlb_stats, :amount, :decimal
  end

  def down
   change_column :mlb_stats, :amount, :integer
  end
end
