class Account < ActiveRecord::Base
  belongs_to :user
  has_many :transactions

  monetize :balance_cents
  monetize :promo_balance_cents
  monetize :clearing_expense_cents

  before_validation do
    self.balance_cents ||= 0
    self.promo_balance_cents ||= 0
    self.clearing_expense_cents ||= 0
  end

  def subtract_from_clearing_expense!(amount)
    update! clearing_expense: (clearing_expense - amount)
  end

end
