class AddReferralFieldsToAccounts < ActiveRecord::Migration[4.2]
  def up
    unless column_exists?(:accounts, :promo_earnings_cents)
      add_column :accounts, :promo_earnings_cents, :integer, default: 0
    end
    unless column_exists?(:accounts, :referral_winnings_cents)
      add_column :accounts, :referral_winnings_cents, :integer, default: 0
    end
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
  end

  def down
    remove_column :accounts, :promo_earnings_cents if column_exists?(:accounts, :promo_earnings_cents)
    remove_column :accounts, :referral_winnings_cents if column_exists?(:accounts, :referral_winnings_cents)
    remove_column :promo_codes, :owner_user_id if column_exists?(:promo_codes, :owner_user_id)
    remove_column :promo_codes, :commission_rate if column_exists?(:promo_codes, :commission_rate)
    remove_column :promo_codes, :treasury_rate if column_exists?(:promo_codes, :treasury_rate)
  end
end
