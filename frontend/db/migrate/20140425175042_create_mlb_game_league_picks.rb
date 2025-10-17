class CreateMlbGameLeaguePicks < ActiveRecord::Migration[4.2]
  def change
    create_table :mlb_game_league_picks do |t|
      t.references :game, index: true
      t.references :league_pick, index: true

      t.timestamps
    end
  end
end
