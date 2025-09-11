class AddMaxContestsToMlbPools < ActiveRecord::Migration
  def change
    add_column :mlb_pools, :max_contests, :integer
  end
end
