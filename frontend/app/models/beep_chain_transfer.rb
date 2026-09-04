# A real on-chain $BEEP movement between a user's wallet and the platform
# treasury. Deposits credit the game balance only after the transaction
# confirms on Cardano; withdrawals debit the balance when the payout is
# submitted on-chain.
class BeepChainTransfer < ActiveRecord::Base
  belongs_to :user

  DIRECTIONS = %w[deposit withdrawal].freeze
  # 'unknown' = payout submission errored ambiguously; the funds stay debited
  # until an admin/on-chain reconciliation resolves whether the tx landed.
  STATUSES   = %w[pending submitting submitted confirmed credited failed unknown].freeze

  validates :direction, inclusion: { in: DIRECTIONS }
  validates :status, inclusion: { in: STATUSES }
  validates :amount_beep, numericality: { greater_than: 0, only_integer: true }
  validates :tx_hash, uniqueness: true, allow_nil: true
  validates :request_key, uniqueness: true, allow_nil: true
  validates :request_key, :destination_address, presence: true, if: :withdrawal?, on: :create

  scope :deposits,    -> { where(direction: 'deposit') }
  scope :withdrawals, -> { where(direction: 'withdrawal') }
  scope :pending,     -> { where(status: 'pending') }

  def explorer_url
    tx_hash.present? ? "https://cardanoscan.io/transaction/#{tx_hash}" : nil
  end

  def withdrawal?
    direction == 'withdrawal'
  end
end
