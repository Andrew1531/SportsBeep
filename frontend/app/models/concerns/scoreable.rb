module Scoreable
  extend ActiveSupport::Concern

  included do
    before_save do
      self.points = multiplier * (amount || 0)
    end
  end

  def multiplier
    stat.try(:multiplier, player) || 0
  end

  def player
    super || NullPlayer.new
  end

end