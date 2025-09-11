class RenameMlbContestsGamePoolIdToTemplateId < ActiveRecord::Migration
  def change
    rename_column :mlb_contests, :game_pool_id, :template_id
  end
end
