class CardanoSwap < ActiveRecord::Base
  belongs_to :user
  belongs_to :swap_asset
  belongs_to :swap_quote
  PAYOUT_METHODS = %w[wallet game_balance].freeze
  STATUSES = %w[pending confirmed paying paid credited failed unknown].freeze
  validates :payout_method, inclusion: { in: PAYOUT_METHODS }
  validates :status, inclusion: { in: STATUSES }
  validates :source_tx_hash, format: { with: /\A[0-9a-f]{64}\z/i }, uniqueness: true

  scope :pending_confirmation, -> { where(status: 'pending') }
  # `unknown` means treasury submission was ambiguous. It is deliberately
  # terminal here: only an operator who reconciles the known transaction hash
  # may change it, preventing an accidental second payout.
  scope :pollable, -> { where(status: %w[pending paying]) }

  def source_explorer_url
    "https://cardanoscan.io/transaction/#{source_tx_hash}"
  end

  def payout_explorer_url
    payout_tx_hash.present? ? "https://cardanoscan.io/transaction/#{payout_tx_hash}" : nil
  end
end