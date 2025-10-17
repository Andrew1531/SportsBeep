class RenameMlbContestsGamePoolIdToTemplateId < ActiveRecord::Migration[4.2]
  def change
    rename_column :mlb_contests, :game_pool_id, :template_id
  end
end
