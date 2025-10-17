class AddAccountReferenceToTransactions < ActiveRecord::Migration[4.2]
  def change
    add_reference :transactions, :account, index: true
    remove_reference :transactions, :contest
  end
end
