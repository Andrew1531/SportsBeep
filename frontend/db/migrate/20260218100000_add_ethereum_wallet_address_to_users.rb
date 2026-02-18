class AddEthereumWalletAddressToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :ethereum_wallet_address, :string
  end
end
