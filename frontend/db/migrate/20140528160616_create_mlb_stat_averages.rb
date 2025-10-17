class CreateMlbStatAverages < ActiveRecord::Migration[4.2]
  def change
    create_table :mlb_stat_averages do |t|
      t.references :player, index: true
      t.string :name
      t.decimal :amount

      t.timestamps
    end
  end
end
