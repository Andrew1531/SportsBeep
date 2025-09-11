class LineupPosition < ActiveRecord::Base
  belongs_to :game
  belongs_to :player, touch: true

  validates :game, presence: true
  validates :player, presence: true

  self.inheritance_column = nil

end
