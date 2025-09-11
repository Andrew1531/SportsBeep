class Stat < ActiveRecord::Base
  belongs_to :player, touch: true
  belongs_to :game, touch: true
  belongs_to :team

  include StatReference
  include Scoreable
  include Formattable

  attr_accessor :sum_points, :sum_amount
  validates :player, :game, presence: true

  def self.total
    sum(:points)
  end

  def self.scored(sport)
    where(stat: sport::SCORED_STATS.map(&:id))
  end

end
