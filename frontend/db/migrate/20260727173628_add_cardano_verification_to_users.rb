class AddCardanoVerificationToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :cardano_stake_address, :string
    add_column :users, :cardano_wallet_name, :string
    add_column :users, :cardano_wallet_verified_at, :datetime
  end
end
