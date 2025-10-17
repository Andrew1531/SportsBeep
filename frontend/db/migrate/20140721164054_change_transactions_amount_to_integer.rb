class ChangeTransactionsAmountToInteger < ActiveRecord::Migration[4.2]
  def up
    change_column :transactions, :amount, :integer, default: 0
  end

  def down
    change_column :transactions, :amount, :string
  end

end
