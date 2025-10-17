class AddUpdatedAtIndexToPlayers < ActiveRecord::Migration[4.2]
  def change
    add_index :players, :updated_at
  end
end
