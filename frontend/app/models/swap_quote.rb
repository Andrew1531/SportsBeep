class SwapQuote < ActiveRecord::Base
  belongs_to :user
  belongs_to :swap_asset
  has_one :cardano_swap, dependent: :restrict_with_exception
  validates :amount_units, :beep_amount, numericality: { only_integer: true, greater_than: 0 }
  validates :beep_per_asset, numericality: { greater_than: 0 }

  def active?
    expires_at > Time.current
  end
end