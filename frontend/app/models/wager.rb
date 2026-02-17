class Wager < ActiveRecord::Base
  belongs_to :user

  monetize :amount_cents
  monetize :potential_payout_cents

  validates :sport, presence: true
  validates :bet_type, presence: true, inclusion: { in: %w[moneyline spread total] }
  validates :selection, presence: true
  validates :odds, presence: true
  validates :amount_cents, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: %w[pending active won lost push cancelled] }

  validate :must_have_beep_balance, on: :create
  validate :must_have_sufficient_balance, on: :create

  scope :pending, -> { where(status: 'pending') }
  scope :active, -> { where(status: 'active') }
  scope :settled, -> { where(status: %w[won lost push]) }
  scope :open, -> { where(status: %w[pending active]) }
  scope :recent, -> { order(created_at: :desc) }

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

  private

  def calculate_potential_payout
    return unless odds && amount_cents && amount_cents > 0
    if odds > 0
      self.potential_payout_cents = amount_cents + (amount_cents * odds / 100.0).round
    else
      self.potential_payout_cents = amount_cents + (amount_cents * 100.0 / odds.abs).round
    end
  end

  def must_have_beep_balance
    account = user&.account
    if account.nil? || account.balance_cents <= 0
      errors.add :base, 'You need $BEEP tokens to place wagers. Visit your Wallet to swap ADA for $BEEP.'
    end
  end

  def must_have_sufficient_balance
    account = user&.account
    return unless account && amount_cents
    if account.balance_cents < amount_cents
      errors.add :base, "Insufficient $BEEP balance. You have #{account.balance} but need #{Money.new(amount_cents).format}."
    end
  end

  def debit_user_account!
    account = user.account
    account.with_lock do
      if account.balance_cents < amount_cents
        raise ActiveRecord::Rollback, 'Insufficient balance'
      end
      account.update!(balance_cents: account.balance_cents - amount_cents)
      account.transactions.create!(
        description: "Wager: #{bet_type_display} - #{matchup}",
        amount_cents: -amount_cents
      )
    end
  end
end
