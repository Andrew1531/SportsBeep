class Wager < ActiveRecord::Base
  belongs_to :user
  belongs_to :approved_token, optional: true

  monetize :amount_cents
  monetize :potential_payout_cents

  validates :sport, presence: true
  validates :bet_type, presence: true, inclusion: { in: %w[moneyline spread total parlay] }
  validates :selection, presence: true
  validates :odds, presence: true
  validates :amount_cents, numericality: { greater_than: 0 }, unless: :token_balance?
  validates :amount_units, numericality: { only_integer: true, greater_than: 0 }, if: :token_balance?
  validates :status, inclusion: { in: %w[pending active won lost push cancelled] }

  validate :must_have_beep_balance, on: :create
  validate :must_have_sufficient_balance, on: :create
  validate :must_use_enabled_token, on: :create

  GAME_DURATION = 4.hours

  scope :pending, -> { where(status: 'pending') }
  scope :active, -> { where(status: 'active') }
  scope :settled, -> { where(status: %w[won lost push]) }
  scope :open, -> { where(status: %w[pending active]) }
  scope :recent, -> { order(created_at: :desc) }
  scope :game_pending, -> { where('game_start_time IS NULL OR game_start_time >= ?', Time.current - GAME_DURATION) }
  scope :game_completed, -> { where.not(game_start_time: nil).where('game_start_time < ?', Time.current - GAME_DURATION) }

  before_validation :calculate_potential_payout, on: :create

  def settled?
    %w[won lost push].include?(status)
  end

  def open?
    %w[pending active].include?(status)
  end

  def odds_display
    return '' unless odds
    if odds > 0
      "+#{odds.to_i}"
    else
      odds.to_i.to_s
    end
  end

  def bet_type_display
    case bet_type
    when 'moneyline' then 'Moneyline'
    when 'spread' then "Spread #{points_display}"
    when 'total' then "#{selection_detail} #{points_display}"
    end
  end

  def points_display
    return '' unless points
    points > 0 ? "+#{points}" : points.to_s
  end

  def status_display
    status.capitalize
  end

  def matchup
    "#{away_team} @ #{home_team}"
  end

  def debit_user_account!
    account = user.account
    account.with_lock do
      if token_balance?
        balance = account.token_balance_for(approved_token)
        raise ActiveRecord::Rollback, 'Insufficient token balance' if balance.balance_units.to_i < wager_units
        balance.update!(balance_units: balance.balance_units.to_i - wager_units)
      elsif account.balance_cents < amount_cents
        raise ActiveRecord::Rollback, 'Insufficient balance'
      else
        account.update!(balance_cents: account.balance_cents - amount_cents)
      end
      AdjustmentTransaction.create!(
        account: account,
        approved_token: approved_token,
        amount_units: token_balance? ? -wager_units : nil,
        description: "Wager: #{bet_type_display} - #{matchup}",
        amount_cents: token_balance? ? 0 : -amount_cents
      )
    end
  end

  # Grade this wager against a final score. Returns 'won', 'lost', 'push', or
  # nil if the bet type cannot be graded automatically (e.g. parlay).
  def grade(home_score, away_score)
    return nil if home_score.nil? || away_score.nil?
    hs = home_score.to_i
    as = away_score.to_i

    case bet_type
    when 'moneyline'
      sel_score, opp_score = team_scores(hs, as)
      return nil if sel_score.nil?
      compare(sel_score, opp_score)
    when 'spread'
      sel_score, opp_score = team_scores(hs, as)
      return nil if sel_score.nil? || points.nil?
      compare(sel_score + points.to_f, opp_score)
    when 'total'
      return nil if points.nil?
      total = hs + as
      line = points.to_f
      if selection.to_s.downcase.include?('over')
        compare(total, line)
      elsif selection.to_s.downcase.include?('under')
        compare(line, total)
      end
    else
      nil # parlay and unknown types are not auto-graded
    end
  end

  # Settle this wager given a final score. Idempotent: only acts on open wagers.
  # Credits payout on a win, refunds the stake on a push, and records the result.
  def settle_with_scores!(home_score, away_score)
    outcome = grade(home_score, away_score)
    return false if outcome.nil?

    settled = false
    with_lock do
      # Re-check status inside the row lock so two concurrent settlers can't
      # both credit the same wager (double-payout guard).
      next unless open?
      update!(status: outcome, result: "#{away_team} #{away_score.to_i} @ #{home_team} #{home_score.to_i}")
      case outcome
      when 'won'
        credit_winnings!("Wager won: #{bet_type_display} - #{matchup}")
      when 'push'
        refund_stake!("Wager push (refund): #{bet_type_display} - #{matchup}")
      end
      settled = true
    end
    settled
  end

  def credit_account!(cents, description)
    return if cents.to_i <= 0
    account = user.account
    account.with_lock do
      if token_balance?
        balance = account.token_balance_for(approved_token)
        units = cents == potential_payout_cents ? potential_payout_units.to_i : wager_units
        balance.update!(balance_units: balance.balance_units.to_i + units)
      else
        account.update!(balance_cents: account.balance_cents + cents.to_i)
      end
      AdjustmentTransaction.create!(
        account: account,
        approved_token: approved_token,
        amount_units: token_balance? ? (cents == potential_payout_cents ? potential_payout_units.to_i : wager_units) : nil,
        description: description,
        amount_cents: cents.to_i
      )
    end
  end

  private

  # Returns [selected_team_score, opponent_score] based on the wager selection,
  # or [nil, nil] when the selection does not match either team.
  def team_scores(home_score, away_score)
    sel = selection.to_s.strip.downcase
    if home_team.to_s.strip.downcase == sel
      [home_score, away_score]
    elsif away_team.to_s.strip.downcase == sel
      [away_score, home_score]
    else
      [nil, nil]
    end
  end

  def compare(a, b)
    if a > b
      'won'
    elsif a < b
      'lost'
    else
      'push'
    end
  end

  def calculate_potential_payout
    return unless odds
    odds_value = odds.to_i
    return if odds_value.zero?

    self.potential_payout_cents = payout_for(amount_cents.to_i, odds_value) unless token_balance?
    self.potential_payout_units = payout_for(wager_units, odds_value) if token_balance? && wager_units.positive?
  end

  def must_have_beep_balance
    account = user&.account
    if account.nil? || (token_balance? ? account.token_balance_for(approved_token).balance_units.to_i <= 0 : account.balance_cents <= 0)
      errors.add :base, "You need #{approved_token&.ticker || '$BEEP'} tokens to place wagers."
    end
  end

  def must_have_sufficient_balance
    account = user&.account
    return unless account && amount_cents
    if token_balance?
      errors.add :base, "Insufficient #{approved_token.ticker} balance." if account.token_balance_for(approved_token).balance_units.to_i < wager_units
    elsif account.balance_cents < amount_cents
      errors.add :base, "Insufficient $BEEP balance. You have #{account.balance} but need #{Money.new(amount_cents).format}."
    end
  end

  def must_use_enabled_token
    errors.add(:approved_token, 'must be an enabled approved token') unless approved_token&.enabled?
  end

  def token_balance?
    approved_token.present?
  end

  def wager_units
    amount_units.presence || amount_cents.to_i
  end

  def payout_for(stake, odds_value)
    return 0 unless stake.positive?

    profit = if odds_value.positive?
               stake * odds_value / 100
             else
               stake * 100 / odds_value.abs
             end
    stake + profit
  end

  def credit_winnings!(description)
    token_balance? ? credit_token_units!(potential_payout_units, description) : credit_account!(potential_payout_cents, description)
  end

  def refund_stake!(description)
    token_balance? ? credit_token_units!(wager_units, description) : credit_account!(amount_cents, description)
  end

  def credit_token_units!(units, description)
    return if units.to_i <= 0

    account = user.account
    account.with_lock do
      balance = account.token_balance_for(approved_token)
      balance.update!(balance_units: balance.balance_units.to_i + units.to_i)
      AdjustmentTransaction.create!(
        account: account, approved_token: approved_token, amount_units: units.to_i,
        amount_cents: 0, description: description
      )
    end
  end

end
