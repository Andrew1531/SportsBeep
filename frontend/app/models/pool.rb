class Pool < ActiveRecord::Base
  before_save { SportsbookOnly.reject! }
  before_destroy { SportsbookOnly.reject! }
  has_many :contest_templates, dependent: :destroy
  has_many :contests, through: :contest_templates

  validates :max_tickets_per_contest, numericality: { greater_than: 0 }

  def entry_fee
    prize_pool.fdiv(max_tickets_per_contest) * entry_fee_multiplier
  end

  def name
    if entry_fee_multiplier == 0 || entry_fee_multiplier.nil?
      "Free — #{prize_pool.to_i} $BEEP Prize Pool"
    else
      fee = entry_fee.round(2)
      "#{fee} $BEEP Entry — #{prize_pool.to_i} $BEEP Prize Pool"
    end
  end

end
