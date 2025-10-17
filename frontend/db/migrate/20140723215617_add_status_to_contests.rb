class AddStatusToContests < ActiveRecord::Migration[4.2]
  def change
    add_column :contests, :status, :string
  end
end
