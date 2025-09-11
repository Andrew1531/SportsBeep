class CreateNflTeamStats < ActiveRecord::Migration
  def change
    create_table :nfl_team_stats do |t|
      t.references :team, index: true
      t.integer :season
      t.string :name
      t.float :amount

      t.timestamps
    end
  end
end
