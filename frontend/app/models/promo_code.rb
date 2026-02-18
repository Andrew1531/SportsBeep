class PromoCode < ActiveRecord::Base
  has_many :users
  belongs_to :owner, class_name: 'User', foreign_key: 'owner_user_id', optional: true

  validates :code, presence: true, uniqueness: true

  def referral_count
    users.count
  end

  def effective_commission_rate
    commission_rate || 0.0001
  end

  def effective_treasury_rate
    treasury_rate || 0.01
  end
end
