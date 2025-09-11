class CreateMlbTeams < ActiveRecord::Migration
  def change
    create_table :mlb_teams do |t|
      t.string :external_id
      t.string :abbr
      t.string :name
      t.string :market
      t.string :league
      t.string :division
      t.string :primary_color
      t.string :secondary_color

      t.timestamps
    end
  end
end
