class CreateTeamGameStats < ActiveRecord::Migration[4.2]
  def change
    create_table :team_game_stats do |t|
      t.references :team, index: true
      t.references :game, index: true
      t.float :amount
      t.float :points
      t.string :type
      t.integer :stat

      t.timestamps
    end
  end
end
