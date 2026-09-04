class BeepWithdrawalConfirmationService
  MIN_CONFIRMATIONS = 2
  CONFIRMATION_WINDOW = 2.hours
  UNSUBMITTED_WINDOW = 10.minutes
  RECONCILABLE_STATUSES = %w[submitting submitted unknown].freeze
  POLLABLE_STATUSES = (['pending'] + RECONCILABLE_STATUSES).freeze

  def initialize(blockfrost: BlockfrostService.new)
    @blockfrost = blockfrost
  end

  def call(transfer)
    return transfer.status unless POLLABLE_STATUSES.include?(transfer.status)
    return expire_unsubmitted_or_wait(transfer) if transfer.tx_hash.blank?
    return transfer.status unless RECONCILABLE_STATUSES.include?(transfer.status)

    confirmations = @blockfrost.tx_confirmations(transfer.tx_hash)
    return expire_or_wait(transfer) if confirmations.nil?
    return transfer.status if confirmations < MIN_CONFIRMATIONS

    utxos = @blockfrost.get_tx_utxos(transfer.tx_hash)
    return transfer.status if utxos.nil?

    received = (utxos['outputs'] || []).sum do |output|
      next 0 unless output['address'] == transfer.destination_address

      (output['amount'] || []).sum do |asset|
        @blockfrost.beep_unit?(asset['unit']) ? asset['quantity'].to_i : 0
      end
    end

    if received < transfer.amount_beep
      refund!(transfer, "Payout transaction did not send the expected $BEEP to the verified wallet.")
      return transfer.reload.status
    end

    transfer.with_lock do
      if RECONCILABLE_STATUSES.include?(transfer.status)
        transfer.update!(status: 'confirmed', confirmed_at: Time.current, error_message: nil)
      end
    end
    transfer.reload.status
  rescue StandardError => e
    Rails.logger.error "withdrawal confirmation error for transfer #{transfer.id}: #{e.class}: #{e.message}"
    transfer.status
  end

  private

  def expire_unsubmitted_or_wait(transfer)
    return transfer.status if transfer.created_at >= UNSUBMITTED_WINDOW.ago

    transfer.with_lock do
      if transfer.status == 'pending' && transfer.tx_hash.blank?
        transfer.update!(
          status: 'failed',
          error_message: 'Withdrawal stopped before blockchain submission. The game balance was not charged.'
        )
      end
    end
    transfer.reload.status
  end

  def expire_or_wait(transfer)
    return transfer.status if transfer.created_at >= CONFIRMATION_WINDOW.ago

    refund!(transfer, 'Payout was not found on-chain before the confirmation window expired.')
    transfer.reload.status
  end

  def refund!(transfer, reason)
    account = transfer.user.account
    account.with_lock do
      transfer.reload
      next unless RECONCILABLE_STATUSES.include?(transfer.status)

      account.update!(balance_cents: account.balance_cents.to_i + transfer.amount_beep * 100)
      Transaction.create!(
        account: account,
        amount_cents: transfer.amount_beep * 100,
        type: 'AdjustmentTransaction',
        description: "Refund: on-chain withdrawal of #{transfer.amount_beep} $BEEP did not confirm.",
        status: 'completed'
      )
      transfer.update!(status: 'failed', error_message: reason)
    end
  end
end