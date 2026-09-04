class CardanoSwapConfirmationService
  MIN_CONFIRMATIONS = 2
  def initialize(blockfrost: BlockfrostService.new)
    @blockfrost = blockfrost
  end

  def call(swap)
    return swap.status unless CardanoSwap::STATUSES.include?(swap.status)
    confirmations = @blockfrost.tx_confirmations(swap.source_tx_hash)
    return 'pending' if confirmations.nil? || confirmations < MIN_CONFIRMATIONS
    utxos = @blockfrost.get_tx_utxos(swap.source_tx_hash)
    return 'pending' unless utxos
    received = (utxos['outputs'] || []).select { |o| o['address'] == ENV['TREASURY_ADDRESS'] }.sum do |o|
      (o['amount'] || []).sum { |a| accepted_unit?(a['unit'], swap.swap_asset) ? a['quantity'].to_i : 0 }
    end
    sender = (utxos['inputs'] || []).any? { |i| CardanoAddress.same_wallet?(i['address'].to_s, swap.user.cardano_wallet_address.to_s) }
    # The signed quote is an exact transfer instruction. Accepting an output
    # larger than it makes a malformed/combined transaction impossible to
    # reconcile safely, so leave it failed for manual support instead.
    unless sender && received == swap.amount_units
      swap.with_lock { swap.update!(status: 'failed', error_message: sender ? 'The exact quoted asset amount did not reach treasury.' : 'Transaction was not sent from your verified wallet.') if swap.status == 'pending' }
      return swap.reload.status
    end
    swap.with_lock { swap.update!(status: 'confirmed', confirmed_at: Time.current) if swap.status == 'pending' }
    pay!(swap.reload) if swap.reload.status == 'confirmed'
    swap.reload.status
  rescue StandardError => e
    Rails.logger.error "swap confirmation #{swap.id}: #{e.class}: #{e.message}"
    swap.status
  end

  private
  def accepted_unit?(unit, asset)
    asset.ada? ? unit.to_s == SwapAsset::ADA_UNIT : unit.to_s == asset.asset_unit
  end

  def pay!(swap)
    if swap.payout_method == 'game_balance'
      swap.user.account.with_lock do
        swap.reload
        next unless swap.status == 'confirmed'
        beep = ApprovedToken.enabled.find_by!(asset_unit: ENV['BEEP_ASSET_UNIT'].to_s.downcase)
        balance = swap.user.account.token_balance_for(beep)
        balance.update!(balance_units: balance.balance_units.to_i + swap.beep_amount)
        Transaction.create!(account: swap.user.account, approved_token: beep, amount_units: swap.beep_amount, amount_cents: 0, type: 'AdjustmentTransaction', description: "Swap credit: #{swap.swap_asset.format_units(swap.amount_units)} #{swap.swap_asset.ticker} → #{swap.beep_amount} BEEP.", status: 'completed')
        swap.update!(status: 'credited')
      end
      return
    end
    CardanoTxTool.with_payout_lock do
      swap.with_lock do
        swap.reload
        next unless swap.status == 'confirmed'
        treasury = ENV['TREASURY_ADDRESS']
        raise CardanoTxTool::Error, 'Treasury ADA reserve is insufficient.' if @blockfrost.get_lovelace_balance(treasury) < CardanoTxTool::MIN_PAYOUT_LOVELACE
        beep_unit = ENV['BEEP_ASSET_UNIT'].to_s.downcase
        raise CardanoTxTool::Error, 'Treasury BEEP reserve is insufficient.' if @blockfrost.get_token_balance(treasury, beep_unit) < swap.beep_amount
        built = CardanoTxTool.build_payout(to_address: swap.user.cardano_wallet_address, unit: beep_unit, amount: swap.beep_amount)
        swap.update!(status: 'paying', payout_tx_hash: built[:tx_hash])
        begin
          submitted = CardanoTxTool.submit_payout(built[:signed_tx])
          raise CardanoTxTool::Error.new('Payout hash mismatch', stage: 'submit', tx_hash: built[:tx_hash]) unless submitted == built[:tx_hash]
          swap.update!(status: 'paid')
        rescue CardanoTxTool::Error => e
          swap.update_columns(status: 'unknown', payout_tx_hash: e.tx_hash.presence || built[:tx_hash], error_message: "Ambiguous payout submission: #{e.message}", updated_at: Time.current)
        end
      end
    end
  end
end