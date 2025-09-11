class AddFieldsToGeneralUser < ActiveRecord::Migration
  def change
    add_column :users, :can_distribute, :boolean
    add_column :users, :username, :string
    add_reference :users, :user, index: true
  end
end
