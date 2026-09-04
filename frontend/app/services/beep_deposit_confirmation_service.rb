class BeepDepositConfirmationService
  MIN_CONFIRMATIONS = 2
  CONFIRMATION_WINDOW = 2.hours

  def initialize(blockfrost: BlockfrostService.new)
    @blockfrost = blockfrost
  end

  # Verify a pending deposit on-chain and credit it exactly once.
  # Returns the transfer's (possibly updated) status string.
  def call(transfer)
    confirmations = @blockfrost.tx_confirmations(transfer.tx_hash)
    return expire_or_wait(transfer) if confirmations.nil?
    return 'pending' if confirmations < MIN_CONFIRMATIONS

    utxos = @blockfrost.get_tx_utxos(transfer.tx_hash)
    return 'pending' if utxos.nil?

    received = (utxos['outputs'] || []).sum do |output|
      next 0 unless output['address'] == ENV['TREASURY_ADDRESS']

      (output['amount'] || []).sum do |asset|
        @blockfrost.beep_unit?(asset['unit']) ? asset['quantity'].to_i : 0
      end
    end
    from_user = (utxos['inputs'] || []).any? do |input|
      CardanoAddress.same_wallet?(input['address'].to_s, transfer.user.cardano_wallet_address.to_s)
    end

    unless received >= transfer.amount_beep && from_user
      message =
        if from_user
          "Only #{received} $BEEP reached the treasury (expected #{transfer.amount_beep})."
        else
          'Transaction was not sent from your verified wallet.'
        end
      transfer.update!(status: 'failed', error_message: message)
      return 'failed'
    end

    account = transfer.user.account
    account.with_lock do
      transfer.reload
      next unless transfer.status == 'pending'

      account.update!(balance_cents: account.balance_cents.to_i + transfer.amount_beep * 100)
      Transaction.create!(
        account: account,
        amount_cents: transfer.amount_beep * 100,
        type: 'AdjustmentTransaction',
        description: "On-chain deposit of #{transfer.amount_beep} $BEEP confirmed (tx #{transfer.tx_hash[0, 16]}…).",
        status: 'completed'
      )
      transfer.update!(status: 'credited', confirmed_at: Time.current)
    end
    transfer.reload.status
  rescue StandardError => e
    Rails.logger.error "deposit confirmation error for transfer #{transfer.id}: #{e.class}: #{e.message}"
    'pending'
  end

  private

  def expire_or_wait(transfer)
    return 'pending' if transfer.created_at >= CONFIRMATION_WINDOW.ago

    transfer.with_lock do
      if transfer.status == 'pending'
        transfer.update!(
          status: 'failed',
          error_message: 'Deposit was not found on-chain before the confirmation window expired.'
        )
      end
    end
    transfer.reload.status
  end
end