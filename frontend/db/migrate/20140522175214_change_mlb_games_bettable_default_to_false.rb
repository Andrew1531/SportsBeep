class ChangeMlbGamesBettableDefaultToFalse < ActiveRecord::Migration[4.2]
  def up
    change_column_default :mlb_games, :bettable, false
    if table_exists?(:mlb_games) && Mlb::Game.count > 0
      Mlb::Game.where(bettable: nil).update_all bettable: false
    end
  end

  def down
    change_column_default :mlb_games, :bettable, nil
  end
end
