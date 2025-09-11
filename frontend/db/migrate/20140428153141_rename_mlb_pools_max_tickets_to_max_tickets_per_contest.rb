class RenameMlbPoolsMaxTicketsToMaxTicketsPerContest < ActiveRecord::Migration
  def change
    rename_column :mlb_pools, :max_tickets, :max_tickets_per_contest
  end
end
