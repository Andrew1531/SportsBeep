class AddOnCurrentRosterToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :on_current_roster, :boolean, null: false, default: false
  end
end
