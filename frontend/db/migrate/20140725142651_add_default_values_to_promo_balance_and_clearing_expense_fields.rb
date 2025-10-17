class AddDefaultValuesToPromoBalanceAndClearingExpenseFields < ActiveRecord::Migration[4.2]
  def up
    change_column :accounts, :clearing_expense_cents, :integer, default: 0
    change_column :accounts, :promo_balance_cents, :integer, default: 0
  end

  def down
    change_column :accounts, :clearing_expense_cents, :integer, default: nil
    change_column :accounts, :promo_balance_cents, :integer, default: nil
  end
end
