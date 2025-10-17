class CreateNflPools < ActiveRecord::Migration[4.2]
  def change
    create_table :nfl_pools do |t|
      t.integer :prize_pool
      t.integer :max_tickets_per_contest
      t.float :entry_fee_multiplier
      t.boolean :default, default: false
      t.integer :max_contests

      t.timestamps
    end
  end
end
