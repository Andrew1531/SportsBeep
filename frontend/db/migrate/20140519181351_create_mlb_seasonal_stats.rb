class CreateMlbSeasonalStats < ActiveRecord::Migration
  def change
    create_table :mlb_seasonal_stats do |t|
      t.references :player, index: true
      t.integer :season
      t.string :name
      t.decimal :amount
      t.float :points

      t.timestamps
    end
  end
end
