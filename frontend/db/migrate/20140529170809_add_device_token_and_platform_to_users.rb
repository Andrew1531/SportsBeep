class AddDeviceTokenAndPlatformToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :device_token, :string
    add_column :users, :platform, :string
  end
end
