class CreateMlbTicketPlayers < ActiveRecord::Migration
  def change
    create_table :mlb_ticket_players do |t|
      t.references :ticket, index: true
      t.references :player, index: true

      t.timestamps
    end
  end
end
