class AddSafetyFieldsToBeepChainTransfers < ActiveRecord::Migration[6.1]
  def change
    add_column :beep_chain_transfers, :request_key, :string
    add_column :beep_chain_transfers, :destination_address, :string

    add_index :beep_chain_transfers, :request_key, unique: true
  end
end