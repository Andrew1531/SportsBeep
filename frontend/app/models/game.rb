class Game < ActiveRecord::Base
  attr_accessor :activated

  belongs_to :home_team, class_name: 'Team'
  belongs_to :away_team, class_name: 'Team'

  has_many :contests, through: :contest_templates
  has_many :contest_templates, dependent: :destroy
  has_many :game_pools, dependent: :destroy
  has_many :pools, through: :game_pools
  has_many :stats, dependent: :destroy
  has_many :team_stats, class_name: 'TeamGameStat', extend: StatBracketsAccessor
  has_many :players, through: :stats

  has_many :lineup_positions
  has_many :lineup_players, -> { uniq }, through: :lineup_positions, source: :player, class_name: 'Player'

  has_many :game_league_picks, dependent: :destroy
  has_many :league_picks, through: :game_league_picks
  has_many :reverse_game_league_picks, class_name: 'GameLeaguePick', foreign_key: :league_pick_id
  has_many :reverse_league_picks, through: :reverse_game_league_picks, source: :game

  has_many :reverse_league_pick_tickets,  class_name: 'Ticket', foreign_key: :league_pick_game_id
  has_many :reverse_league_pick_contests, class_name: 'Contest', through: :reverse_league_pick_tickets, source: :contest

  validates :home_team, presence: true
  validates :away_team, presence: true
  validates :pools, length: { minimum: 1 }, if: :bettable?

  scope :bettable, -> { where bettable: true }
  scope :live,     -> { where status: [:live, :ended] }
  scope :upcoming, -> { future.bettable.where status: ['', nil] }
  scope :between,  -> (a, b) { where(start_time: a..b).order(:start_time) }
  scope :past,     -> (timeframe = 20.years) { where(start_time: timeframe.ago..Time.now).order(:start_time) }
  scope :future,   -> { where(start_time: Time.now..20.years.from_now) }
  scope :before,   -> (timestamp) { where(start_time: 20.years.ago...timestamp) }
  scope :eligible, -> { where('status IS NULL OR status NOT IN(?, ?)', 'postponed', 'suspended') }

  after_save :enqueue_game_import_worker, if: :activated

  def teams
    [home_team, away_team]
  end

  def upcoming?
    future? && bettable?
  end

  def future?
    start_time.future?
  end

  def status?(status)
    self.status.to_s == status.to_s
  end

  def has_official_lineup?
    (%w[SP C 1B 2B 3B SS LF CF RF] - lineup_positions.joins(player: :team).where(teams: { id: home_team.id }).pluck(:position)).empty? &&
    (%w[SP C 1B 2B 3B SS LF CF RF] - lineup_positions.joins(player: :team).where(teams: { id: away_team.id }).pluck(:position)).empty?
  end

  def players
    Player.where(team: teams)
  end

  def cache_key
    [super, home_team, away_team]
  end

  private

    def enqueue_game_import_worker
      raise 'Implement #enqueue_game_import_worker!'
    end

end
