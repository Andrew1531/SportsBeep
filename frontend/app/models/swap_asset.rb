class SwapAsset < ActiveRecord::Base
  ADA_UNIT = 'lovelace'.freeze
  has_many :swap_quotes, dependent: :restrict_with_exception
  has_many :cardano_swaps, dependent: :restrict_with_exception
  scope :enabled, -> { where(enabled: true) }

  validates :asset_unit, presence: true, uniqueness: { case_sensitive: false }
  validates :ticker, presence: true
  validates :decimals, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 18 }
  validates :beep_per_asset, numericality: { greater_than: 0 }
  validate :complete_native_unit_or_ada

  before_validation { self.asset_unit = asset_unit.to_s.strip.downcase }

  def ada?
    asset_unit == ADA_UNIT
  end

  def format_units(units)
    TokenAmount.format(units, decimals: decimals)
  end

  def parse_amount!(value)
    TokenAmount.parse(value, decimals: decimals)
  end

  private

  def complete_native_unit_or_ada
    return if ada?
    # A policy ID alone is not a currency identifier. Require at least one
    # asset-name byte so a registry entry can never silently accept every
    # token minted under a policy.
    errors.add(:asset_unit, 'must be ADA (lovelace) or a complete policy ID plus asset-name unit') unless asset_unit.match?(/\A[0-9a-f]{56}(?:[0-9a-f]{2}){1,32}\z/i)
    errors.add(:policy_id, 'must match the asset unit policy ID') unless policy_id.to_s.downcase == asset_unit[0, 56]
  end
end