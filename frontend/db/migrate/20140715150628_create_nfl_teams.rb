class CreateNflTeams < ActiveRecord::Migration[4.2]
  def change
    create_table :nfl_teams do |t|
      t.string :external_id
      t.string :abbr
      t.string :name
      t.string :market
      t.string :league
      t.string :conference
      t.string :division
      t.string :primary_color
      t.string :secondary_color

      t.timestamps
    end
  end
end
