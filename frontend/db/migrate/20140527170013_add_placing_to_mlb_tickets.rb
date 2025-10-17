class AddPlacingToMlbTickets < ActiveRecord::Migration[4.2]
  def change
    add_column :mlb_tickets, :placing, :integer
  end
end
