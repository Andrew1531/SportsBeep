class AddDefaultToMlbPools < ActiveRecord::Migration[4.2]
  def change
    add_column :mlb_pools, :default, :boolean, default: false
  end
end
