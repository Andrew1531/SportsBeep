class AddPromoBalanceCentsToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :promo_balance_cents, :integer
  end
end
