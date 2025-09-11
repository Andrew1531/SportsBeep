class CreateMlbSeasons < ActiveRecord::Migration
  def change
    create_table :mlb_seasons do |t|
      t.string :external_id
      t.integer :year
      t.string :type
      t.boolean :current

      t.timestamps
    end
  end
end
