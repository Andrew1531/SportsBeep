class CreateBaseballGames < ActiveRecord::Migration[4.2]
  def change
    create_table :baseball_games do |t|
      t.string :sportsdata_id
      t.boolean :bettable, default: false
      t.datetime :game_time
      t.string :status
      t.boolean :been_polled, default: false
      t.belongs_to :baseball_season
      t.timestamps
    end
  end
end
