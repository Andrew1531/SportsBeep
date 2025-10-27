class ChangeFinalizedGamesToEndedAndTheirContestsToFinalized < ActiveRecord::Migration[4.2]
  def change
    if table_exists?(:games)
      execute "UPDATE games SET status = 'ended' WHERE status = 'finalized'" rescue nil
      execute "UPDATE contests SET status = 'finalized' FROM games WHERE contests.game_id = games.id AND games.status = 'finalized'" rescue nil
    end
  end
end
