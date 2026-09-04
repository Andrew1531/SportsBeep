class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
    @account = @user.account
    @recent_transactions = safe_collection { @account.transactions.order(created_at: :desc).limit(5) }
    load_wallet_info
    load_referral_info
    @ticker_items = build_ticker_items
  end

  def wallet
    @user = current_user
    @account = @user.account
    @transactions = safe_collection { @account.transactions.order(created_at: :desc).limit(20) }
    load_wallet_info
    load_referral_info
    sportsbook_in_play = safe_collection { @user.wagers.open }.sum(&:amount_cents) / 100.0
    active_tickets = safe_collection do
      @user.tickets
           .joins(contest: { template: :pool })
           .where.not(contests: { status: 'finalized' })
           .includes(contest: { template: :pool })
    end
    fantasy_in_play = active_tickets.sum { |t| t.contest.pool.entry_fee }
    @active_wager_total = sportsbook_in_play + fantasy_in_play
    @total_wager_count = safe_collection { @user.wagers }.size
  end

  def transactions
    @user = current_user
    @account = @user.account
    @transactions = safe_collection { @account.transactions.order(created_at: :desc) }
  end

  def redeem_promo
    @user = current_user
  end

  def apply_promo
    @user = current_user
    code = params[:promo_code].to_s.strip.upcase

    promo = PromoCode.find_by(code: code)
    if promo.nil?
      flash[:alert] = "Invalid promo code."
    elsif promo.respond_to?(:expired?) && promo.expired?
      flash[:alert] = "This promo code has expired."
    elsif promo.respond_to?(:max_uses) && promo.max_uses.present? && promo.users_count >= promo.max_uses
      flash[:alert] = "This promo code has reached its maximum uses."
    elsif @user.promo_code_id.present?
      flash[:alert] = "You have already redeemed a promo code."
    else
      @user.update(promo_code: promo)
      flash[:notice] = "Promo code '#{code}' applied successfully!"
    end

    redirect_to redeem_promo_path
  end

  def vending
    @user = current_user
    @account = @user.account
    load_wallet_info
  end

  # Step 1 of CIP-30 connection: issue a one-time challenge the wallet must sign.
  def cardano_nonce
    nonce = "SportsBeep wallet verification #{SecureRandom.hex(16)} at #{Time.current.to_i}"
    session[:cardano_nonce] = nonce
    session[:cardano_nonce_issued_at] = Time.current.to_i
    render json: { nonce: nonce }
  end

  # Step 2: verify the CIP-8 signature from the wallet extension and save the
  # verified addresses. Expects JSON from the wallet connect script.
  def connect_cardano
    @user = current_user

    nonce = session[:cardano_nonce].to_s
    issued_at = session[:cardano_nonce_issued_at].to_i
    if nonce.blank? || issued_at < 10.minutes.ago.to_i
      return render json: { ok: false, error: 'Verification challenge expired. Please try connecting again.' }, status: :unprocessable_entity
    end

    signed_hex   = params[:signed_address_hex].to_s.strip
    payment_hex  = params[:address_hex].to_s.strip
    signature    = params[:signature].to_s.strip
    key          = params[:key].to_s.strip
    wallet_name  = params[:wallet_name].to_s.strip.first(50)

    unless [signed_hex, payment_hex, signature, key].all? { |v| v.present? && v.match?(/\A[0-9a-fA-F]+\z/) }
      return render json: { ok: false, error: 'Missing or malformed wallet data.' }, status: :unprocessable_entity
    end

    signed_bytes  = [signed_hex].pack('H*')
    payment_bytes = [payment_hex].pack('H*')

    unless CardanoAddress.mainnet?(signed_bytes) && CardanoAddress.mainnet?(payment_bytes)
      return render json: { ok: false, error: 'Please switch your wallet to the Cardano mainnet and try again.' }, status: :unprocessable_entity
    end

    result = CardanoSignatureService.verify(
      signature_hex: signature,
      key_hex: key,
      address_bytes: signed_bytes,
      expected_payload: nonce
    )
    unless result.valid
      return render json: { ok: false, error: result.error }, status: :unprocessable_entity
    end

    # The signed address must belong to the same wallet as the payment address:
    # either it IS the payment address, or it's the reward address whose stake
    # credential is embedded in the payment (base) address.
    linked =
      if CardanoAddress.reward_address?(signed_bytes)
        CardanoAddress.stake_credential_hash(payment_bytes) == CardanoAddress.credential_hash(signed_bytes)
      else
        signed_bytes == payment_bytes
      end
    unless linked
      return render json: { ok: false, error: 'The signed address does not belong to the connected wallet.' }, status: :unprocessable_entity
    end

    payment_bech32 = CardanoAddress.bytes_to_bech32(payment_bytes)
    stake_bech32   = CardanoAddress.reward_address?(signed_bytes) ? CardanoAddress.bytes_to_bech32(signed_bytes) : nil

    # update_columns: these are system-set fields; unrelated user validations
    # (e.g. profile completeness) must not block wallet verification.
    @user.update_columns(
      cardano_wallet_address: payment_bech32,
      cardano_stake_address: stake_bech32,
      cardano_wallet_name: wallet_name.presence,
      cardano_wallet_verified_at: Time.current,
      updated_at: Time.current
    )
    session.delete(:cardano_nonce)
    session.delete(:cardano_nonce_issued_at)

    render json: { ok: true, address: payment_bech32, stake_address: stake_bech32 }
  rescue StandardError => e
    Rails.logger.error "connect_cardano error for user #{current_user&.id}: #{e.class}: #{e.message}"
    render json: { ok: false, error: 'Could not connect wallet. Please try again.' }, status: :internal_server_error
  end

  def disconnect_cardano
    current_user.update(
      cardano_wallet_address: nil,
      cardano_stake_address: nil,
      cardano_wallet_name: nil,
      cardano_wallet_verified_at: nil
    )
    flash[:notice] = "Cardano wallet disconnected."
    redirect_to safe_redirect_path
  end

  def load_beep
    @user = current_user
    @account = @user.account

    unless @user.cardano_wallet_address.present?
      flash[:alert] = "Connect your Cardano wallet first."
      return redirect_to wallet_path
    end

    unless @user.cardano_wallet_verified_at.present?
      flash[:alert] = "Please verify wallet ownership first — reconnect your wallet and sign the verification message."
      return redirect_to wallet_path
    end

    unless ENV['BLOCKFROST_PROJECT_ID'].present?
      flash[:alert] = "Blockchain service is not configured."
      return redirect_to wallet_path
    end

    amount_beep = params[:amount].to_s.strip.to_i
    if amount_beep <= 0
      flash[:alert] = "Enter a whole number of $BEEP greater than 0 to load."
      return redirect_to wallet_path
    end

    begin
      service = BlockfrostService.new
      on_chain_beep = service.get_beep_balance(@user.cardano_wallet_address).to_i

      if on_chain_beep <= 0
        flash[:alert] = "No $BEEP tokens detected in your connected wallet."
        return redirect_to wallet_path
      end

      error = nil
      # Lock the account row and re-check limits inside the lock so two
      # concurrent loads can't both pass the check against stale balances.
      @account.with_lock do
        available_beep = @account.available_to_load_cents(on_chain_beep * 100) / 100

        if available_beep <= 0
          error = "You've already loaded all of your on-chain $BEEP into the game."
          next
        end

        if amount_beep > available_beep
          error = "You can load at most #{available_beep} $BEEP from your connected wallet."
          next
        end

        load_cents = amount_beep * 100
        @account.update!(
          balance_cents:     @account.balance_cents.to_i + load_cents,
          beep_loaded_cents: @account.beep_loaded_cents_safe + load_cents
        )
        Transaction.create!(
          account:      @account,
          amount_cents: load_cents,
          type:         'AdjustmentTransaction',
          description:  "Unlocked #{amount_beep} $BEEP play credit (gated by Cardano wallet holdings). Tokens stay in wallet.",
          status:       'completed'
        )
      end

      if error
        flash[:alert] = error
      else
        flash[:notice] = "Unlocked #{amount_beep} $BEEP of play credit. Your real tokens stay safe in your wallet."
      end
    rescue => e
      Rails.logger.error "BEEP load error for user #{@user.id}: #{e.message}"
      flash[:alert] = "Could not load $BEEP right now. Please try again shortly."
    end

    redirect_to wallet_path
  end

  # --- On-chain $BEEP transfers (real token movement via the treasury) ---

  # Build an unsigned deposit transaction (user wallet -> treasury) that the
  # wallet extension will sign and submit.
  def build_deposit
    @user = current_user
    return render json: { ok: false, error: 'On-chain transfers are not enabled yet.' }, status: :service_unavailable unless on_chain_mode?
    return render json: { ok: false, error: 'Verify wallet ownership first.' }, status: :forbidden unless @user.cardano_wallet_verified_at.present?

    amount = params[:amount].to_s.strip.to_i
    return render json: { ok: false, error: 'Enter a whole number of $BEEP greater than 0.' }, status: :unprocessable_entity if amount <= 0

    user_addr =
      if params[:address_hex].to_s.match?(/\A[0-9a-fA-F]+\z/) && params[:address_hex].present?
        CardanoAddress.hex_to_bech32(params[:address_hex].to_s.strip)
      else
        @user.cardano_wallet_address
      end
    unless user_addr.start_with?('addr1') && CardanoAddress.same_wallet?(user_addr, @user.cardano_wallet_address)
      return render json: { ok: false, error: 'The connected wallet does not match your verified wallet.' }, status: :forbidden
    end

    beep = CardanoTxTool.find_beep_unit(user_addr)
    if beep[:quantity] < amount
      return render json: { ok: false, error: "Your wallet holds #{beep[:quantity]} $BEEP at this address — not enough to send #{amount}." }, status: :unprocessable_entity
    end

    unsigned_tx = CardanoTxTool.build_deposit(
      user_address: user_addr,
      treasury_address: ENV['TREASURY_ADDRESS'],
      unit: beep[:unit],
      amount: amount
    )
    render json: { ok: true, unsigned_tx: unsigned_tx }
  rescue CardanoTxTool::Error => e
    render json: { ok: false, error: e.message }, status: :unprocessable_entity
  rescue StandardError => e
    Rails.logger.error "build_deposit error for user #{current_user&.id}: #{e.class}: #{e.message}"
    render json: { ok: false, error: 'Could not build the deposit transaction.' }, status: :internal_server_error
  end

  # Record a submitted deposit so the confirmation watcher can credit it.
  def record_deposit
    @user = current_user
    return render json: { ok: false, error: 'On-chain transfers are not enabled yet.' }, status: :service_unavailable unless on_chain_mode?

    tx_hash = params[:tx_hash].to_s.strip.downcase
    amount = params[:amount].to_s.strip.to_i
    unless tx_hash.match?(/\A[0-9a-f]{64}\z/) && amount.positive?
      return render json: { ok: false, error: 'Invalid transaction details.' }, status: :unprocessable_entity
    end

    transfer = BeepChainTransfer.create!(user: @user, direction: 'deposit', amount_beep: amount, tx_hash: tx_hash, status: 'pending')
    render json: { ok: true, transfer_id: transfer.id }
  rescue ActiveRecord::RecordInvalid
    render json: { ok: false, error: 'This transaction was already recorded.' }, status: :unprocessable_entity
  end

  # Check the user's pending deposits on-chain and credit confirmed ones.
  def check_deposits
    @user = current_user
    return render json: { ok: false, error: 'On-chain transfers are not enabled yet.' }, status: :service_unavailable unless on_chain_mode?

    results = @user.beep_chain_transfers.deposits.pending.limit(10).map do |transfer|
      { id: transfer.id, status: settle_deposit(transfer) }
    end
    render json: { ok: true, results: results }
  end

  def withdraw_beep
    return onchain_withdraw if on_chain_mode?

    @user = current_user
    @account = @user.account

    amount_beep = params[:amount].to_s.strip.to_i
    if amount_beep <= 0
      flash[:alert] = "Enter a whole number of $BEEP greater than 0 to withdraw."
      return redirect_to wallet_path
    end

    begin
      error = nil
      # Lock the account and re-check inside so concurrent withdrawals can't
      # both pass the bound check against a stale balance.
      @account.with_lock do
        # You can only pull back $BEEP that is actually sitting in your game
        # balance AND was loaded from your wallet (not winnings/promo credit).
        withdrawable_beep = [@account.balance_cents.to_i, @account.beep_loaded_cents_safe].min / 100

        if withdrawable_beep <= 0
          error = "There is no wallet-backed play credit available to remove."
          next
        end

        if amount_beep > withdrawable_beep
          error = "You can remove at most #{withdrawable_beep} $BEEP of play credit."
          next
        end

        withdraw_cents = amount_beep * 100
        @account.update!(
          balance_cents:     @account.balance_cents.to_i - withdraw_cents,
          beep_loaded_cents: [@account.beep_loaded_cents_safe - withdraw_cents, 0].max
        )
        Transaction.create!(
          account:      @account,
          amount_cents: -withdraw_cents,
          type:         'AdjustmentTransaction',
          description:  "Removed #{amount_beep} $BEEP of play credit from game balance (no on-chain transfer).",
          status:       'completed'
        )
      end

      if error
        flash[:alert] = error
      else
        flash[:notice] = "Removed #{amount_beep} $BEEP of play credit. Your real tokens were never moved — they're still in your wallet."
      end
    rescue => e
      Rails.logger.error "BEEP withdraw error for user #{@user.id}: #{e.message}"
      flash[:alert] = "Could not withdraw $BEEP right now. Please try again shortly."
    end

    redirect_to wallet_path
  end

  private

  def on_chain_mode?
    # Both are required: without a strict policy ID, deposit verification
    # could be spoofed by look-alike tokens.
    ENV['TREASURY_ADDRESS'].present? && ENV['BEEP_POLICY_ID'].present?
  end
  helper_method :on_chain_mode?

  # Verify a pending deposit on-chain and credit it exactly once.
  # Returns the transfer's (possibly updated) status string.
  def settle_deposit(transfer)
    service = BlockfrostService.new
    confirmations = service.tx_confirmations(transfer.tx_hash)
    return 'pending' if confirmations.nil? # not on-chain yet

    if confirmations < 2
      return 'pending' # wait for a safer confirmation depth
    end

    utxos = service.get_tx_utxos(transfer.tx_hash)
    return 'pending' if utxos.nil?

    treasury = ENV['TREASURY_ADDRESS']
    received = 0
    (utxos['outputs'] || []).each do |output|
      next unless output['address'] == treasury
      (output['amount'] || []).each do |asset|
        received += asset['quantity'].to_i if service.beep_unit?(asset['unit'])
      end
    end

    from_user = (utxos['inputs'] || []).any? do |input|
      CardanoAddress.same_wallet?(input['address'].to_s, transfer.user.cardano_wallet_address.to_s)
    end

    if received < transfer.amount_beep || !from_user
      transfer.update!(status: 'failed', error_message: from_user ? "Only #{received} $BEEP reached the treasury (expected #{transfer.amount_beep})." : 'Transaction was not sent from your verified wallet.')
      return 'failed'
    end

    account = transfer.user.account
    account.with_lock do
      transfer.reload
      next unless transfer.status == 'pending' # idempotency under concurrency

      account.update!(balance_cents: account.balance_cents.to_i + transfer.amount_beep * 100)
      Transaction.create!(
        account:      account,
        amount_cents: transfer.amount_beep * 100,
        type:         'AdjustmentTransaction',
        description:  "On-chain deposit of #{transfer.amount_beep} $BEEP confirmed (tx #{transfer.tx_hash[0, 16]}…).",
        status:       'completed'
      )
      transfer.update!(status: 'credited', confirmed_at: Time.current)
    end
    transfer.reload.status
  rescue StandardError => e
    Rails.logger.error "settle_deposit error for transfer #{transfer.id}: #{e.class}: #{e.message}"
    'pending'
  end

  # Real on-chain withdrawal: debit the game balance, then pay out $BEEP from
  # the treasury to the user's verified address. Refund on failure.
  def onchain_withdraw
    @user = current_user
    @account = @user.account

    unless @user.cardano_wallet_verified_at.present?
      flash[:alert] = 'Verify wallet ownership first — reconnect your wallet and sign the verification message.'
      return redirect_to wallet_path
    end

    amount_beep = params[:amount].to_s.strip.to_i
    if amount_beep <= 0
      flash[:alert] = 'Enter a whole number of $BEEP greater than 0 to withdraw.'
      return redirect_to wallet_path
    end

    transfer = nil
    error = nil
    @account.with_lock do
      max_beep = @account.balance_cents.to_i / 100
      if amount_beep > max_beep
        error = "You can withdraw at most #{max_beep} $BEEP."
        next
      end

      @account.update!(balance_cents: @account.balance_cents.to_i - amount_beep * 100)
      transfer = BeepChainTransfer.create!(user: @user, direction: 'withdrawal', amount_beep: amount_beep, status: 'pending')
      Transaction.create!(
        account:      @account,
        amount_cents: -(amount_beep * 100),
        type:         'AdjustmentTransaction',
        description:  "On-chain withdrawal of #{amount_beep} $BEEP to your Cardano wallet (processing).",
        status:       'completed'
      )
    end

    if error
      flash[:alert] = error
      return redirect_to wallet_path
    end

    begin
      treasury_beep = CardanoTxTool.find_beep_unit(ENV['TREASURY_ADDRESS'])
      raise CardanoTxTool::Error, 'Treasury has insufficient $BEEP right now. Please try again later.' if treasury_beep[:quantity] < amount_beep

      tx_hash = CardanoTxTool.payout(to_address: @user.cardano_wallet_address, unit: treasury_beep[:unit], amount: amount_beep)
      transfer.update!(tx_hash: tx_hash, status: 'confirmed', confirmed_at: Time.current)
      flash[:notice] = "Withdrawal submitted! #{amount_beep} $BEEP is on its way to your wallet. Tx: #{tx_hash[0, 16]}…"
    rescue StandardError => e
      Rails.logger.error "onchain_withdraw payout error for user #{@user.id}: #{e.class}: #{e.message}"
      if e.is_a?(CardanoTxTool::Error) && e.ambiguous_submission?
        # The submit step errored — the transaction MAY still have reached the
        # network. Never auto-refund here, or a landed payout would double-pay.
        transfer&.update!(status: 'unknown', error_message: "Ambiguous submission: #{e.message.to_s.first(180)}")
        flash[:alert] = 'Your withdrawal was submitted but confirmation is uncertain. Your balance stays debited while we verify it on-chain — contact support if it does not resolve shortly.'
      else
        # Failure before submission — the payout never made it on-chain, safe to refund.
        @account.with_lock do
          @account.update!(balance_cents: @account.balance_cents.to_i + amount_beep * 100)
          Transaction.create!(
            account:      @account,
            amount_cents: amount_beep * 100,
            type:         'AdjustmentTransaction',
            description:  "Refund: on-chain withdrawal of #{amount_beep} $BEEP failed (#{e.message.to_s.first(80)}).",
            status:       'completed'
          )
        end
        transfer&.update!(status: 'failed', error_message: e.message.to_s.first(200))
        flash[:alert] = "Withdrawal failed and your balance was refunded: #{e.message.to_s.first(120)}"
      end
    end

    redirect_to wallet_path
  end

  def safe_collection
    yield
  rescue NameError, NoMethodError
    []
  end

  def safe_redirect_path
    redirect_path = params[:redirect_to].to_s
    if redirect_path.present? && redirect_path.start_with?('/') && !redirect_path.start_with?('//') && !redirect_path.include?('\\')
      redirect_path
    else
      wallet_path
    end
  end

  def load_wallet_info
    if @user.cardano_wallet_address.present? && ENV['BLOCKFROST_PROJECT_ID'].present?
      begin
        service = BlockfrostService.new
        @wallet_info = service.get_address_info(@user.cardano_wallet_address)
        @on_chain_beep = service.get_beep_balance(@user.cardano_wallet_address)
      rescue => e
        Rails.logger.error "Wallet info error: #{e.message}"
        @wallet_info = { ada_balance: 0.0, tokens: [], status: 'error' }
        @on_chain_beep = 0
      end
    else
      @wallet_info = nil
      @on_chain_beep = 0
    end

    if @account
      @available_to_load_beep = @account.available_to_load_cents(@on_chain_beep.to_i * 100) / 100
      @withdrawable_beep = [@account.balance_cents.to_i, @account.beep_loaded_cents_safe].min / 100
    else
      @available_to_load_beep = 0
      @withdrawable_beep = 0
    end
  end

  def load_referral_info
    @owned_promo = safe_collection { PromoCode.where(owner_user_id: @user.id) }.first
    @referral_count = @owned_promo ? @owned_promo.referral_count : 0
    @promo_earnings = @account.promo_earnings_dollars
    @referral_winnings = @account.referral_winnings_dollars
    @total_referral_earnings = @account.total_referral_earnings_dollars
  end

  def build_ticker_items
    items = []
    items += [
      { sport: 'MLB', emoji: '⚾', home: 'Yankees', away: 'Red Sox',       home_ml: -175, away_ml: +148, status: 'Today 7:05 PM ET' },
      { sport: 'MLB', emoji: '⚾', home: 'Dodgers',  away: 'Giants',        home_ml: -160, away_ml: +138, status: 'Today 10:10 PM ET' },
      { sport: 'MLB', emoji: '⚾', home: 'Astros',   away: 'Rangers',       home_ml: -130, away_ml: +110, status: 'Today 8:10 PM ET' },
      { sport: 'MLB', emoji: '⚾', home: 'Braves',   away: 'Mets',          home_ml: -145, away_ml: +122, status: 'Today 7:20 PM ET' },
      { sport: 'NBA', emoji: '🏀', home: 'Celtics',  away: 'Lakers',        home_ml: -200, away_ml: +170, status: 'Tonight 7:30 PM ET' },
      { sport: 'NBA', emoji: '🏀', home: 'Nuggets',  away: 'Warriors',      home_ml: -150, away_ml: +130, status: 'Tonight 10:00 PM ET' },
      { sport: 'NBA', emoji: '🏀', home: 'Bucks',    away: 'Suns',          home_ml: -135, away_ml: +115, status: 'Tonight 8:00 PM ET' },
      { sport: 'NHL', emoji: '🏒', home: 'Oilers',   away: 'Maple Leafs',   home_ml: -130, away_ml: +110, status: 'Tonight 7:00 PM ET' },
      { sport: 'NHL', emoji: '🏒', home: 'Avalanche',away: 'Golden Knights', home_ml: +105, away_ml: -125, status: 'Tonight 9:30 PM ET' },
      { sport: 'NFL', emoji: '🏈', home: 'Chiefs',   away: 'Bills',         home_ml: -155, away_ml: +132, status: 'Sun 4:25 PM ET' },
      { sport: 'NFL', emoji: '🏈', home: 'Eagles',   away: 'Cowboys',       home_ml: -135, away_ml: +114, status: 'Sun 8:20 PM ET' },
    ]
    items
  end
end
