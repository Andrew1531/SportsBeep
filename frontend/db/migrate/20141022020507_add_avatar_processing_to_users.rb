class AddAvatarProcessingToUsers < ActiveRecord::Migration
  def change
    add_column :users, :avatar_processing, :boolean, default: false, null: false
  end
end
