class GameLeaguePick < ActiveRecord::Base
  belongs_to :game
  belongs_to :league_pick, class_name: 'Game'
end
