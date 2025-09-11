class ChangeMlbGamesBettableDefaultToFalse < ActiveRecord::Migration
  def up
    change_column_default :mlb_games, :bettable, false
    Mlb::Game.where(bettable: nil).update_all bettable: false
  end

  def down
    change_column_default :mlb_games, :bettable, nil
  end
end
