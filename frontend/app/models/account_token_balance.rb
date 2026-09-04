class AccountTokenBalance < ActiveRecord::Base
  belongs_to :account
  belongs_to :approved_token

  validates :balance_units, :loaded_units, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def available_to_load_units(on_chain_units)
    [on_chain_units.to_i - loaded_units.to_i, 0].max
  end

  def debit!(units)
    raise ArgumentError, 'amount must be positive' unless units.to_i.positive?
    raise InsufficientBalance, 'Insufficient token balance.' if balance_units.to_i < units.to_i
    update!(balance_units: balance_units.to_i - units.to_i)
  end

  class InsufficientBalance < StandardError; end
end