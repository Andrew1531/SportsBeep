class ApprovedToken < ActiveRecord::Base
  has_many :account_token_balances, dependent: :restrict_with_exception
  has_many :transactions, dependent: :restrict_with_exception
  has_many :beep_chain_transfers, dependent: :restrict_with_exception

  scope :enabled, -> { where(enabled: true) }

  # A Cardano asset unit is the complete policy id followed by an asset name
  # of at most 32 bytes (hex encoded).  Do not use a policy id as a token
  # lookup: assets under one policy are distinct currencies.
  validates :asset_unit, format: { with: /\A[0-9a-f]{56}(?:[0-9a-f]{2}){0,32}\z/i }, uniqueness: { case_sensitive: false }
  validates :policy_id, format: { with: /\A[0-9a-f]{56}\z/i }
  validates :display_name, :ticker, presence: true
  validates :ticker, uniqueness: { case_sensitive: false }
  validates :decimals, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 18 }
  validate :unit_has_policy_id

  def self.for_unit!(unit)
    enabled.find_by!(asset_unit: unit.to_s.strip.downcase)
  end

  def format_units(units)
    TokenAmount.format(units, decimals: decimals)
  end

  def parse_amount!(value)
    TokenAmount.parse(value, decimals: decimals)
  end

  private

  before_validation do
    self.asset_unit = asset_unit.to_s.strip.downcase if asset_unit.present?
    self.policy_id = policy_id.to_s.strip.downcase if policy_id.present?
  end

  def unit_has_policy_id
    return unless asset_unit.present? && policy_id.present?

    errors.add(:asset_unit, 'must begin with its exact policy ID') unless asset_unit[0, 56] == policy_id
  end
end