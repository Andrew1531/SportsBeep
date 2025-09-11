class Player < ActiveRecord::Base
  belongs_to :team

  mount_uploader :headshot, HeadshotUploader

  has_many :stats,          -> { extending(StatBracketsAccessor).order(:name) }
  has_many :seasonal_stats, -> { extending(StatBracketsAccessor).order(:name) }
  has_many :recent_stats,   -> { extending(StatBracketsAccessor).order(:name) }

  has_many :ticket_players
  has_many :lineup_positions
  has_many :players, through: :ticket_players
  has_many :games, through: :stats

  def name
    "#{first_name} #{last_name}"
  end

  def to_s
    name
  end

  def position_in(game)
    lineup_position = if lineup_positions.loaded?
      lineup_positions.find { |lp| lp.game == game }
    else
      lineup_positions.find_by(game: game)
    end
    lineup_position.try(:position) || position
  end

  def self.on_current_roster
    where(on_current_roster: true)
  end

  def self.on_official_lineup_for_game(game)
    all.merge(game.lineup_players)
  end

end
