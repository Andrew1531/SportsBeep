class CreateWagers < ActiveRecord::Migration[4.2]
  def change
    create_table :wagers do |t|
      t.references :user, index: true
      t.string :sport, null: false
      t.string :league
      t.string :fixture_id
      t.string :game_id
      t.string :home_team
      t.string :away_team
      t.datetime :game_start_time
      t.string :bet_type, null: false
      t.string :selection, null: false
      t.string :selection_detail
      t.decimal :odds, precision: 10, scale: 2
      t.decimal :points, precision: 5, scale: 1
      t.integer :amount_cents, default: 0, null: false
      t.integer :potential_payout_cents, default: 0, null: false
      t.string :status, default: 'pending', null: false
      t.string :result
      t.string :sportsbook
      t.timestamps null: false
    end

    add_index :wagers, :status
    add_index :wagers, :sport
    add_index :wagers, [:user_id, :status]
  end
end
