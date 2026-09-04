class Ticket < ActiveRecord::Base

  attr_accessor :game, :pool, :roster

  belongs_to :user
  belongs_to :approved_token, optional: true
  belongs_to :contest, counter_cache: true, touch: true
  belongs_to :league_pick_game, class_name: 'Game'
  belongs_to :league_pick_team, class_name: 'Team'

  has_one :contest_template, through: :contest, source: :template

  has_many :ticket_players, dependent: :destroy
  has_many :ticket_squads, dependent: :destroy
  has_many :players, through: :ticket_players
  has_many :squads, through: :ticket_squads, source: :team

  has_many :timer_states, dependent: :destroy
  has_many :questions, through: :contest
  has_many :answers, -> { extending BestOrBustScoring }, class_name: 'QuestionAnswer', dependent: :destroy
  has_many :stats, -> (ticket) { where(game: ticket.contest.game) }, through: :players

  before_validation(on: :create, unless: :contest) do
    EnterContest.new(self).call(game, pool)
  end

  validates :contest, presence: true
  validates :league_pick_team, presence: true, if: :league_pick_game

  validate :must_only_choose_a_player_one_time_per_ticket
  validate :must_only_include_players_from_the_contests_game
  validate :must_only_allow_up_to_5_players_from_a_single_team
  validate :must_have_a_valid_roster, if: :roster
  # validate :league_pick_game_must_be_included_in_the_contest_games_league_pick_games, if: :league_pick_game
  # validate :league_pick_team_must_be_playing_in_the_league_pick_game, if: :league_pick_game
  validate :must_not_join_the_same_contest_twice_per_user, on: :create
  validate :must_not_join_the_same_game_and_pool_more_than_5_times, on: :create
  validate :must_be_saved_before_game_time
  validate :must_have_beep_balance, on: :create
  validate :must_use_enabled_token, on: :create

  after_create { GenerateTimerStates.new.call(self) }

  def score
    cached_score || score!
  end

  def placing
    cached_placing || super || placing!
  end

  def best_or_bust_score
    cached_best_or_bust_score || answers.score
  end

  def score!
    stats.total + league_pick.score + answers.score + ticket_squads.map(&:score).sum
  end

  def placing!
    Ticket.where(contest: contest).to_a.sort_by(&:score).reverse.index(self) + 1
  end

  def positions
    @positions ||= players.map(&:position)
  end

  def game
    @game || contest.try(:game)
  end

  def pool
    @pool || contest.try(:pool)
  end

  def cache_key
    "#{super}-#{score}-#{placing}"
  end

  def policy_class
    TicketPolicy
  end

  def editable_by?(user)
    (self.user == user) && game.start_time.future?
  end

  def league_pick
    @_lp ||= NullLeaguePick.new
  end

  private

    def must_only_choose_a_player_one_time_per_ticket
      if players.uniq != players
        errors.add :players, 'must contain a particular player only once'
      end
    end

    def must_only_include_players_from_the_contests_game
      if (players.map(&:id) - game.players.pluck(:id)).any?
        errors.add :players, 'must all be on a team from the chosen game'
      end
    end

    def must_only_allow_up_to_5_players_from_a_single_team
      teams = players.map(&:team)
      if teams.count(game.home_team) > 5 || teams.count(game.away_team) > 5
        errors.add :base, 'No more than 5 players on your roster can come from a single team'
      end
    end

    def must_have_a_valid_roster
      errors.add :base, roster.errors[:base].first if roster.invalid?
    end

    def league_pick_game_must_be_included_in_the_contest_games_league_pick_games
      unless contest.game.league_picks.include? league_pick_game
        errors.add :league_pick_game, "Must be in the contest's available league pick games"
      end
    end

    def league_pick_team_must_be_playing_in_the_league_pick_game
      unless league_pick_game.teams.include? league_pick_team
        errors.add :league_pick_team, 'Must be playing in the league pick game'
      end
    end

    def must_be_saved_before_game_time
      if game.start_time.past?
        errors.add :base, "You cannot join a game that is already in progress"
      end
    end

    def must_have_beep_balance
      account = user&.account
      if account.nil? || !approved_token || account.token_balance_for(approved_token).balance_units.to_i <= 0
        errors.add :base, "You need #{approved_token&.ticker || 'an approved token'} tokens to enter a contest."
      end
    end

    def must_use_enabled_token
      errors.add(:approved_token, 'must be an enabled approved token') unless approved_token&.enabled?
    end

    def must_not_join_the_same_contest_twice_per_user
      errors.add :base, 'You cannot join the same contest twice' if contest.users.include? user
    end

    def must_not_join_the_same_game_and_pool_more_than_5_times
      if user.tickets.joins(:contest_template).where(contest_templates: { game_id: contest.game, pool_id: contest.pool }).count >= 5
        errors.add :base, 'You have joined this game and pool the maximum number of times (5)'
      end
    end

end
