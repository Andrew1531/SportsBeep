class Contest < ActiveRecord::Base
  belongs_to :template, class_name: 'ContestTemplate'

  has_one :game, through: :template
  has_one :pool, through: :template

  has_many :league_picks, through: :game
  has_many :league_pick_games, through: :tickets

  has_many :tickets, dependent: :destroy
  has_many :questions, through: :template
  has_many :users, through: :tickets

  scope :live,      -> { joins(:game).merge(Game.live).where('contests.status != ? OR contests.status IS NULL', :finalized) }
  scope :upcoming,  -> { joins(:game).merge Game.upcoming }
  scope :past,      -> { where(status: :finalized) }
  scope :finalized, -> { past }

  validate :pool_must_not_be_at_contest_limit
  validate :must_not_be_at_ticket_limit

  def self.open
    where 'tickets_count < (?)', joins(:pool).select('pools.max_tickets_per_contest').limit(1)
  end

  # checks if all league pick games and the contest game itself have ended
  def finalizable?
    games = league_pick_games.to_a << game
    games.all? do |game|
      next unless game
      game.status.to_s.in? %w(ended postponed suspended)
    end
  end

  def policy_class
    ContestPolicy
  end

  private

    def pool_must_not_be_at_contest_limit
      if pool.max_contests && pool.contests.size >= pool.max_contests
        errors[:pool] << 'has reached the maximum number of contests'
      end
    end

    def must_not_be_at_ticket_limit
      if pool.max_tickets_per_contest && tickets.size > pool.max_tickets_per_contest
        errors[:tickets] << 'has reached the maximum allowed for this contest'
      end
    end

end
