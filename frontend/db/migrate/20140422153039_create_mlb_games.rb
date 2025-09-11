class CreateMlbGames < ActiveRecord::Migration
  def change
    create_table :mlb_games do |t|
      t.string :external_id
      t.boolean :bettable
      t.datetime :start_time
      t.string :status
      t.references :home_team, index: true
      t.references :away_team, index: true
      t.references :season, index: true

      t.timestamps
    end
  end
end
