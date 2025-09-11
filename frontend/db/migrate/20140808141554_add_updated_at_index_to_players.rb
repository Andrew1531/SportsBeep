class AddUpdatedAtIndexToPlayers < ActiveRecord::Migration
  def change
    add_index :players, :updated_at
  end
end
