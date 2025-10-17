class AddTeamReferenceToMlbStats < ActiveRecord::Migration[4.2]
  def change
    add_reference :mlb_stats, :team, index: true
  end
end
