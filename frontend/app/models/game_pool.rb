class GamePool < ActiveRecord::Base
  before_save { SportsbookOnly.reject! }
  before_destroy { SportsbookOnly.reject! }
  belongs_to :game
  belongs_to :pool

  validates :game_id, uniqueness: { scope: :pool_id }

end
