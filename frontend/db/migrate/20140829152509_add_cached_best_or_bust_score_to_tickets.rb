class AddCachedBestOrBustScoreToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :cached_best_or_bust_score, :float
  end
end
