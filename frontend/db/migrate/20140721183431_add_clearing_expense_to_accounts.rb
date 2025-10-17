class AddClearingExpenseToAccounts < ActiveRecord::Migration[4.2]
  def change
    add_column :accounts, :clearing_expense_cents, :integer
  end
end
