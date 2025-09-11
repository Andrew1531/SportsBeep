class AddDefaultToMlbPools < ActiveRecord::Migration
  def change
    add_column :mlb_pools, :default, :boolean, default: false
  end
end
