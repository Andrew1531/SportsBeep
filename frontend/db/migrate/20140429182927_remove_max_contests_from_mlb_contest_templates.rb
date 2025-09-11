class RemoveMaxContestsFromMlbContestTemplates < ActiveRecord::Migration
  def change
    remove_column :mlb_contest_templates, :max_contests
  end
end
