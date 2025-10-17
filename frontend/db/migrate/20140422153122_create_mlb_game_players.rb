class CreateMlbGamePlayers < ActiveRecord::Migration[4.2]
  def change
    create_table :mlb_game_players do |t|
      t.references :game, index: true
      t.references :player, index: true

      t.timestamps
    end
  end
end
