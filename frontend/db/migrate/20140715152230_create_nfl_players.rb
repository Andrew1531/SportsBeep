class CreateNflPlayers < ActiveRecord::Migration
  def change
    create_table :nfl_players do |t|
      t.references :team, index: true
      t.string :external_id
      t.string :first_name
      t.string :last_name
      t.string :number
      t.string :status
      t.string :position

      t.timestamps
    end
  end
end
