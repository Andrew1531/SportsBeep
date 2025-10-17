class AddAvatarUuidToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :avatar_uuid, :string
  end
end
