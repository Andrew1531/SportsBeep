class AddCardanoWalletAddressToUsers < ActiveRecord::Migration[6.1]
  def up
    unless column_exists?(:users, :cardano_wallet_address)
      add_column :users, :cardano_wallet_address, :string
    end
  end

  def down
    remove_column :users, :cardano_wallet_address if column_exists?(:users, :cardano_wallet_address)
  end
end
