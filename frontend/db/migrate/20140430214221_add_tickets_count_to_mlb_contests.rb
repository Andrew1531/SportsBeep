class AddTicketsCountToMlbContests < ActiveRecord::Migration
  def change
    add_column :mlb_contests, :tickets_count, :integer, default: 0
  end
end
