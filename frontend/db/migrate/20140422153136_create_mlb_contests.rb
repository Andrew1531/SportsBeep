class CreateMlbContests < ActiveRecord::Migration[4.2]
  def change
    create_table :mlb_contests do |t|
      t.references :game_pool, index: true

      t.timestamps
    end
  end
end
