class AddAvatarProcessingToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :avatar_processing, :boolean, default: false, null: false
  end
end
