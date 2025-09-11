class AddPlacingToMlbTickets < ActiveRecord::Migration
  def change
    add_column :mlb_tickets, :placing, :integer
  end
end
