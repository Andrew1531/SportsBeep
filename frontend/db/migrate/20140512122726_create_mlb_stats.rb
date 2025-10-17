class CreateMlbStats < ActiveRecord::Migration[4.2]
  def change
    create_table :mlb_stats do |t|
      t.references :player, index: true
      t.references :game, index: true
      t.string :name
      t.integer :amount
      t.float :points

      t.timestamps
    end
  end
end
