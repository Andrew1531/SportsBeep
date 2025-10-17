class AddTicketsCountToMlbContests < ActiveRecord::Migration[4.2]
  def change
    add_column :mlb_contests, :tickets_count, :integer, default: 0
  end
end
