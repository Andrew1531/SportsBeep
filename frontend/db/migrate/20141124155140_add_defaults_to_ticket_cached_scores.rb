class AddDefaultsToTicketCachedScores < ActiveRecord::Migration[4.2]
  def up
    change_column :tickets, :cached_score, :float, default: 0.0
    change_column :tickets, :cached_best_or_bust_score, :float, default: 0.0
  end

  def down
    change_column :tickets, :cached_score, :float, default: nil
    change_column :tickets, :cached_best_or_bust_score, :float, default: nil
  end
end
