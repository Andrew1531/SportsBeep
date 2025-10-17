class AddMaxContestsToMlbPools < ActiveRecord::Migration[4.2]
  def change
    add_column :mlb_pools, :max_contests, :integer
  end
end
