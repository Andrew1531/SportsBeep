class CreateNflGamePools < ActiveRecord::Migration
  def change
    create_table :nfl_game_pools do |t|
      t.references :game, index: true
      t.references :pool, index: true

      t.timestamps
    end
  end
end
