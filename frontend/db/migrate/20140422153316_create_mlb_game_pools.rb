class CreateMlbGamePools < ActiveRecord::Migration[4.2]
  def change
    create_table :mlb_game_pools do |t|
      t.references :game, index: true
      t.references :pool, index: true
      t.integer :max_contests

      t.timestamps
    end
  end
end
