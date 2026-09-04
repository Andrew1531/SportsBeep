class Transaction < ActiveRecord::Base

  CREDIT_CLEARING_EXPENSE_RATE = 0.02

  belongs_to :account
  belongs_to :approved_token, optional: true
  has_one :user, through: :account

  monetize :amount_cents
  before_validation { self.amount_cents ||= 0 }
  before_validation { self.description  ||= to_s }

  validates :amount, presence: true
  validates :description, presence: true
  validates :type, presence: true
  validates :account, presence: true

  def self.commit(user, amount)
    amount = Money.new(amount.to_cents)
    user.account.transactions.build(amount: amount, type: self.name).tap do |transaction|
      transaction.commit!
    end
  end

  def commit!
    ActiveRecord::Base.transaction do
      yield if block_given?
      update! description: to_s, amount: modify_amount(amount)
      account.update balance: account.balance + amount
    end
  end

  def self.total_deposits
    sum(:amount)
  end

  def to_s
    'N/A'
  end

  def modify_amount(amount)
    amount
  end

end
