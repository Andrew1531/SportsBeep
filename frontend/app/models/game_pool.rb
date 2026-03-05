class GamePool < ActiveRecord::Base
  belongs_to :game
  belongs_to :pool

  validates :game_id, uniqueness: { scope: :pool_id }

end
