class AddReferralFieldsToAccounts < ActiveRecord::Migration[4.2]
  def change
    add_column :accounts, :promo_earnings_cents, :integer, default: 0
    add_column :accounts, :referral_winnings_cents, :integer, default: 0
    add_column :promo_codes, :owner_user_id, :integer
    add_column :promo_codes, :commission_rate, :decimal, precision: 8, scale: 5, default: 0.0001
    add_column :promo_codes, :treasury_rate, :decimal, precision: 8, scale: 5, default: 0.01
    add_index :promo_codes, :owner_user_id
  end
end
