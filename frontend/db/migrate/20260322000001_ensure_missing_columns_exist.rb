class EnsureMissingColumnsExist < ActiveRecord::Migration[6.1]
  def up
    # accounts — promo and referral fields
    unless column_exists?(:accounts, :promo_earnings_cents)
      add_column :accounts, :promo_earnings_cents, :integer, default: 0
    end
    unless column_exists?(:accounts, :referral_winnings_cents)
      add_column :accounts, :referral_winnings_cents, :integer, default: 0
    end

    # users — Cardano wallet address only
    unless column_exists?(:users, :cardano_wallet_address)
      add_column :users, :cardano_wallet_address, :string
    end

    # promo_codes — MLM fields
    unless column_exists?(:promo_codes, :owner_user_id)
      add_column :promo_codes, :owner_user_id, :integer
    end
    unless column_exists?(:promo_codes, :commission_rate)
      add_column :promo_codes, :commission_rate, :decimal, precision: 8, scale: 5, default: 0.0001
    end
    unless column_exists?(:promo_codes, :treasury_rate)
      add_column :promo_codes, :treasury_rate, :decimal, precision: 8, scale: 5, default: 0.01
    end
    unless index_exists?(:promo_codes, :owner_user_id)
      add_index :promo_codes, :owner_user_id
    end

    # wagers table
    unless table_exists?(:wagers)
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

  def down
  end
end
