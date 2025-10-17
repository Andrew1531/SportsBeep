class RemoveMaxContestsFromMlbContestTemplates < ActiveRecord::Migration[4.2]
  def change
    remove_column :mlb_contest_templates, :max_contests
  end
end
