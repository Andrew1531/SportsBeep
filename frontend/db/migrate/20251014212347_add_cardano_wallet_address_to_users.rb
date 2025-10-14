class AddCardanoWalletAddressToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :cardano_wallet_address, :string
  end
end
