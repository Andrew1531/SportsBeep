class AddAncestryToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :ancestry, :string, index: true
  end
end
