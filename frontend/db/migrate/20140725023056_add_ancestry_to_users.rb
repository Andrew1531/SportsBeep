class AddAncestryToUsers < ActiveRecord::Migration
  def change
    add_column :users, :ancestry, :string, index: true
  end
end
