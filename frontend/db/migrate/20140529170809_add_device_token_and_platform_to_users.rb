class AddDeviceTokenAndPlatformToUsers < ActiveRecord::Migration
  def change
    add_column :users, :device_token, :string
    add_column :users, :platform, :string
  end
end
