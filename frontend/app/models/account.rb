class Account < ActiveRecord::Base
  belongs_to :user
  has_many :transactions
  has_many :account_token_balances, dependent: :destroy
  has_many :approved_tokens, through: :account_token_balances

  monetize :balance_cents
  monetize :promo_balance_cents
  monetize :clearing_expense_cents

  before_validation do
    self.balance_cents ||= 0
    self.promo_balance_cents ||= 0
    self.clearing_expense_cents ||= 0
    self.promo_earnings_cents ||= 0
    self.referral_winnings_cents ||= 0
    self.beep_loaded_cents ||= 0 if has_attribute?(:beep_loaded_cents)
  end

  # How much on-chain $BEEP (in cents) the user has already moved into their
  # game balance. Used to cap further loads at their actual wallet holdings.
  def beep_loaded_cents_safe
    has_attribute?(:beep_loaded_cents) ? (beep_loaded_cents || 0) : 0
  end

  # Cents still available to load from the connected wallet, given the current
  # on-chain holdings (in cents). Never negative.
  def available_to_load_cents(on_chain_cents)
    [on_chain_cents.to_i - beep_loaded_cents_safe, 0].max
  end

  def token_balance_for(token)
    account_token_balances.find_or_create_by!(approved_token: token)
  end

  def subtract_from_clearing_expense!(amount)
    update! clearing_expense: (clearing_expense - amount)
  end

  def promo_earnings_dollars
    (promo_earnings_cents || 0) / 100.0
  end

  def referral_winnings_dollars
    (referral_winnings_cents || 0) / 100.0
  end

  def total_referral_earnings_dollars
    promo_earnings_dollars + referral_winnings_dollars
  end

end
