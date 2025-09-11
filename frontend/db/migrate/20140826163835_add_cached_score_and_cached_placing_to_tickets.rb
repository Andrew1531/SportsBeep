class AddCachedScoreAndCachedPlacingToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :cached_score, :float
    add_column :tickets, :cached_placing, :integer
  end
end
