class AddOnCurrentRosterToPlayers < ActiveRecord::Migration[4.2]
  def change
    add_column :players, :on_current_roster, :boolean, null: false, default: false
  end
end
