class AddAccountReferenceToTransactions < ActiveRecord::Migration
  def change
    add_reference :transactions, :account, index: true
    remove_reference :transactions, :contest
  end
end
