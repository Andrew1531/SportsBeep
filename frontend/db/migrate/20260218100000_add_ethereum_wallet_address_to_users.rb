class AddEthereumWalletAddressToUsers < ActiveRecord::Migration[4.2]
  def up
    unless column_exists?(:users, :ethereum_wallet_address)
      add_column :users, :ethereum_wallet_address, :string
    end
  end

  def down
    remove_column :users, :ethereum_wallet_address if column_exists?(:users, :ethereum_wallet_address)
  end
end
