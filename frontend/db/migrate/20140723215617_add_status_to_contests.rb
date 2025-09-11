class AddStatusToContests < ActiveRecord::Migration
  def change
    add_column :contests, :status, :string
  end
end
