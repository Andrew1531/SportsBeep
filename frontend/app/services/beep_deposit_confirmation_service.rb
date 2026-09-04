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
        exact_token_unit?(asset['unit'], transfer) ? asset['quantity'].to_i : 0
      end
    end
    from_user = (utxos['inputs'] || []).any? do |input|
      CardanoAddress.same_wallet?(input['address'].to_s, transfer.user.cardano_wallet_address.to_s)
    end

    unless received >= transfer.amount_in_units && from_user
      message =
        if from_user
          "Only #{received} #{token_label(transfer)} reached the treasury (expected #{transfer.amount_in_units})."
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

      credit_token!(account, transfer)
      Transaction.create!(
        account: account,
        approved_token: transfer.approved_token,
        amount_units: transfer.amount_in_units,
        amount_cents: transfer.approved_token ? 0 : transfer.amount_beep * 100,
        type: 'AdjustmentTransaction',
        description: "On-chain deposit of #{transfer.amount_in_units} #{token_label(transfer)} confirmed (tx #{transfer.tx_hash[0, 16]}…).",
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

  def exact_token_unit?(unit, transfer)
    transfer.approved_token ? @blockfrost.approved_unit?(unit, transfer.approved_token) : @blockfrost.beep_unit?(unit)
  end

  def token_label(transfer)
    transfer.approved_token&.ticker || '$BEEP'
  end

  def credit_token!(account, transfer)
    if transfer.approved_token
      balance = account.token_balance_for(transfer.approved_token)
      balance.update!(balance_units: balance.balance_units.to_i + transfer.amount_in_units)
    else
      account.update!(balance_cents: account.balance_cents.to_i + transfer.amount_beep * 100)
    end
  end

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