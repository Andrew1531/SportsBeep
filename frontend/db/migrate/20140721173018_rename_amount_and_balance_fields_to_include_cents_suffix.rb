class RenameAmountAndBalanceFieldsToIncludeCentsSuffix < ActiveRecord::Migration[4.2]
  def change
    rename_column :accounts, :balance, :balance_cents
    rename_column :gl_accounts, :balance, :balance_cents
    rename_column :transactions, :amount, :amount_cents
  end
end
