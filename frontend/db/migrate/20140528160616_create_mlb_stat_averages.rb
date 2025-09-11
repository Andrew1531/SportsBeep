class CreateMlbStatAverages < ActiveRecord::Migration
  def change
    create_table :mlb_stat_averages do |t|
      t.references :player, index: true
      t.string :name
      t.decimal :amount

      t.timestamps
    end
  end
end
