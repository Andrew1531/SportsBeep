class AddLeaguePickReferencesToMlbTickets < ActiveRecord::Migration
  def change
    add_reference :mlb_tickets, :league_pick_game, index: true
    add_reference :mlb_tickets, :league_pick_team, index: true
  end
end
