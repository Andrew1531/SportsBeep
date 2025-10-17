class AddCachedBestOrBustScoreToTickets < ActiveRecord::Migration[4.2]
  def change
    add_column :tickets, :cached_best_or_bust_score, :float
  end
end
