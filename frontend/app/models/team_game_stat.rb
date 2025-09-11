class TeamGameStat < ActiveRecord::Base
  belongs_to :team
  belongs_to :game

  include StatReference
  include Formattable

  validates :team, :game, :stat, presence: true

end
