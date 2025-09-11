class AddPositionToMlbTicketPlayers < ActiveRecord::Migration
  def change
    add_column :mlb_ticket_players, :position, :string
  end
end
