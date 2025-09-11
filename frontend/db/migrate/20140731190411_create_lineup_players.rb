class CreateLineupPlayers < ActiveRecord::Migration
  def change
    create_table :lineup_players do |t|
      t.references :game, index: true
      t.references :player, index: true
      t.string :position

      t.timestamps
    end
  end
end
