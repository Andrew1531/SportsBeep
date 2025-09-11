class CreateMlbPools < ActiveRecord::Migration
  def change
    create_table :mlb_pools do |t|
      t.integer :prize_pool
      t.integer :max_tickets
      t.float :entry_fee_multiplier

      t.timestamps
    end
  end
end
