class AddLeaguePickReferencesToMlbTickets < ActiveRecord::Migration[4.2]
  def change
    add_reference :mlb_tickets, :league_pick_game, index: true
    add_reference :mlb_tickets, :league_pick_team, index: true
  end
end
