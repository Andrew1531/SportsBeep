class CreateMlbStatTopics < ActiveRecord::Migration[4.2]
  def change
    create_table :mlb_stat_topics do |t|
      t.string :stat
      t.string :comparison

      t.timestamps
    end
  end
end
