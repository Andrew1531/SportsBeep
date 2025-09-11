class Team < ActiveRecord::Base

  has_many :players
  has_many :stats, class_name: 'TeamStat', extend: StatBracketsAccessor
  has_many :game_stats, class_name: 'TeamGameStat', extend: StatBracketsAccessor

  before_validation :strip_pound_sign_from_colors

  validates :name, :abbr, :external_id, presence: true
  validates :primary_color, :secondary_color, hex: true, allow_blank: true

  def to_s
    "#{market} #{name}"
  end

  def average_hr_per_game
    0
  end

  def has_colors?
    primary_color.present? && secondary_color.present?
  end

  def games
    Game.where('home_team_id = :id OR away_team_id = :id', id: id)
  end

  private

    def strip_pound_sign_from_colors
      primary_color.try   :gsub!, '#', ''
      secondary_color.try :gsub!, '#', ''
    end

end
