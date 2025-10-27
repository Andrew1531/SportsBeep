class ChangeMlbGamesBettableDefaultToFalse < ActiveRecord::Migration[4.2]
  def up
    change_column_default :mlb_games, :bettable, false
    if table_exists?(:mlb_games)
      execute "UPDATE mlb_games SET bettable = false WHERE bettable IS NULL" rescue nil
    end
  end

  def down
    change_column_default :mlb_games, :bettable, nil
  end
end
