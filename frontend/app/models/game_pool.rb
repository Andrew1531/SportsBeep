class GamePool < ActiveRecord::Base
  belongs_to :game
  belongs_to :pool

  validate :game, uniqueness: { scope: :pool }

end
