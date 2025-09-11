class AddTeamReferenceToMlbStats < ActiveRecord::Migration
  def change
    add_reference :mlb_stats, :team, index: true
  end
end
