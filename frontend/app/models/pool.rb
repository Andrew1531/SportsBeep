class Pool < ActiveRecord::Base
  has_many :contest_templates, dependent: :destroy
  has_many :contests, through: :contest_templates

  validates :max_tickets_per_contest, numericality: { greater_than: 0 }

  def entry_fee
    prize_pool.fdiv(max_tickets_per_contest) * entry_fee_multiplier
  end

end
