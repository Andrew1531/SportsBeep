class CreateMlbPlayers < ActiveRecord::Migration
  def change
    create_table :mlb_players do |t|
      t.references :team, index: true
      t.string :external_id
      t.string :first_name
      t.string :last_name
      t.integer :number
      t.integer :batting_hand
      t.integer :throwing_hand
      t.string :status
      t.string :position

      t.timestamps
    end
  end
end
