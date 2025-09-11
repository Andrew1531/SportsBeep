class AddClearingExpenseToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :clearing_expense_cents, :integer
  end
end
