class CreateNflGamePools < ActiveRecord::Migration[4.2]
  def change
    create_table :nfl_game_pools do |t|
      t.references :game, index: true
      t.references :pool, index: true

      t.timestamps
    end
  end
end
