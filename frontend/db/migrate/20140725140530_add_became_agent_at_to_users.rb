class AddBecameAgentAtToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :became_agent_at, :datetime
  end
end
