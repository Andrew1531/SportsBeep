class AddPositionToMlbTicketPlayers < ActiveRecord::Migration[4.2]
  def change
    add_column :mlb_ticket_players, :position, :string
  end
end
