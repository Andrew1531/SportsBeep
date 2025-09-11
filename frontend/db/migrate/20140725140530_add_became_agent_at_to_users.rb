class AddBecameAgentAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :became_agent_at, :datetime
  end
end
