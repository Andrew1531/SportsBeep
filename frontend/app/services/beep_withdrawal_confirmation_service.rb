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
        exact_token_unit?(asset['unit'], transfer) ? asset['quantity'].to_i : 0
      end
    end

    if received < transfer.amount_in_units
      refund!(transfer, "Payout transaction did not send the expected #{token_label(transfer)} to the verified wallet.")
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

      if transfer.approved_token
        balance = account.token_balance_for(transfer.approved_token)
        balance.update!(balance_units: balance.balance_units.to_i + transfer.amount_in_units)
      else
        account.update!(balance_cents: account.balance_cents.to_i + transfer.amount_beep * 100)
      end
      Transaction.create!(
        account: account,
        approved_token: transfer.approved_token,
        amount_units: transfer.amount_in_units,
        amount_cents: transfer.approved_token ? 0 : transfer.amount_beep * 100,
        type: 'AdjustmentTransaction',
        description: "Refund: on-chain withdrawal of #{transfer.amount_in_units} #{token_label(transfer)} did not confirm.",
        status: 'completed'
      )
      transfer.update!(status: 'failed', error_message: reason)
    end
  end

  def exact_token_unit?(unit, transfer)
    transfer.approved_token ? @blockfrost.approved_unit?(unit, transfer.approved_token) : @blockfrost.beep_unit?(unit)
  end

  def token_label(transfer)
    transfer.approved_token&.ticker || '$BEEP'
  end
end