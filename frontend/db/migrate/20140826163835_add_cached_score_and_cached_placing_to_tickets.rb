class AddCachedScoreAndCachedPlacingToTickets < ActiveRecord::Migration[4.2]
  def change
    add_column :tickets, :cached_score, :float
    add_column :tickets, :cached_placing, :integer
  end
end
