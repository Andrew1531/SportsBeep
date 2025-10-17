class AddPromoBalanceCentsToAccounts < ActiveRecord::Migration[4.2]
  def change
    add_column :accounts, :promo_balance_cents, :integer
  end
end
