class CreateMlbTeamStats < ActiveRecord::Migration
  def change
    create_table :mlb_team_stats do |t|
      t.references :team, index: true
      t.integer :season
      t.string :name
      t.float :amount

      t.timestamps
    end
  end
end
