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
    @approved_tokens = ApprovedToken.enabled.order(:ticker)
    @selected_token = approved_token_from_params || @approved_tokens.first
    @token_balances = @approved_tokens.index_with { |token| @account.token_balance_for(token) }
    settle_pending_deposits
    settle_pending_withdrawals
    @transactions = safe_collection do
      scope = @account.transactions.order(created_at: :desc)
      @selected_token ? scope.where(approved_token: @selected_token).limit(20) : scope.limit(20)
    end
    @chain_transfers = safe_collection do
      scope = @user.beep_chain_transfers.order(created_at: :desc)
      @selected_token ? scope.where(approved_token: @selected_token).limit(5) : scope.none
    end
    load_wallet_info
    load_referral_info
    sportsbook_in_play = safe_collection { @user.wagers.open.where(approved_token: @selected_token) }.sum(&:amount_units)
    active_tickets = safe_collection do
      @user.tickets
           .joins(contest: { template: :pool })
           .where.not(contests: { status: 'finalized' })
           .includes(contest: { template: :pool })
    end
    fantasy_in_play = active_tickets.select { |t| t.approved_token_id == @selected_token&.id }.sum(&:entry_fee_units)
    @active_wager_total = sportsbook_in_play + fantasy_in_play
    @total_wager_count = safe_collection { @user.wagers }.size
  end

  def transactions
    @user = current_user
    @account = @user.account
    token = approved_token_from_params
    @transactions = safe_collection do
      scope = @account.transactions.order(created_at: :desc)
      token ? scope.where(approved_token: token) : scope
    end
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

  # --- On-chain approved-token transfers (real token movement via treasury) ---

  # Build an unsigned deposit transaction (user wallet -> treasury) that the
  # wallet extension will sign and submit.
  def build_deposit
    @user = current_user
    return render json: { ok: false, error: 'On-chain transfers are not enabled yet.' }, status: :service_unavailable unless on_chain_mode?
    return render json: { ok: false, error: 'Verify wallet ownership first.' }, status: :forbidden unless @user.cardano_wallet_verified_at.present?

    token = approved_token_from_params
    return render json: { ok: false, error: 'Choose an approved token.' }, status: :unprocessable_entity unless token
    amount = token.parse_amount!(params[:amount])

    user_addr =
      if params[:address_hex].to_s.match?(/\A[0-9a-fA-F]+\z/) && params[:address_hex].present?
        CardanoAddress.hex_to_bech32(params[:address_hex].to_s.strip)
      else
        @user.cardano_wallet_address
      end
    unless user_addr.start_with?('addr1') && CardanoAddress.same_wallet?(user_addr, @user.cardano_wallet_address)
      return render json: { ok: false, error: 'The connected wallet does not match your verified wallet.' }, status: :forbidden
    end

    asset = CardanoTxTool.find_unit(user_addr, token.asset_unit)
    if asset[:quantity] < amount
      return render json: { ok: false, error: "Your wallet holds #{token.format_units(asset[:quantity])} #{token.ticker} at this address — not enough to send #{token.format_units(amount)}." }, status: :unprocessable_entity
    end

    unsigned_tx = CardanoTxTool.build_deposit(
      user_address: user_addr,
      treasury_address: ENV['TREASURY_ADDRESS'],
      unit: asset[:unit],
      amount: amount
    )
    render json: { ok: true, unsigned_tx: unsigned_tx }
  rescue TokenAmount::InvalidAmount => e
    render json: { ok: false, error: e.message }, status: :unprocessable_entity
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
    return render json: { ok: false, error: 'Verify wallet ownership first.' }, status: :forbidden unless @user.cardano_wallet_verified_at.present?

    tx_hash = params[:tx_hash].to_s.strip.downcase
    token = approved_token_from_params
    return render json: { ok: false, error: 'Choose an approved token.' }, status: :unprocessable_entity unless token
    amount = token.parse_amount!(params[:amount])
    unless tx_hash.match?(/\A[0-9a-f]{64}\z/) && amount.positive?
      return render json: { ok: false, error: 'Invalid transaction details.' }, status: :unprocessable_entity
    end

    transfer = BeepChainTransfer.create!(user: @user, approved_token: token, direction: 'deposit', amount_beep: amount, amount_units: amount, tx_hash: tx_hash, status: 'pending')
    BeepDepositConfirmationJob.perform_later(transfer.id)
    render json: { ok: true, transfer_id: transfer.id, explorer_url: transfer.explorer_url }
  rescue TokenAmount::InvalidAmount => e
    render json: { ok: false, error: e.message }, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    existing = BeepChainTransfer.find_by(tx_hash: tx_hash)
    if existing&.user_id == @user.id && existing.direction == 'deposit' && existing.amount_in_units == amount && existing.approved_token_id == token&.id
      render json: { ok: true, transfer_id: existing.id, explorer_url: existing.explorer_url, already_recorded: true }
    else
      render json: { ok: false, error: 'This transaction was already recorded with different details.' }, status: :unprocessable_entity
    end
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
    # The full unit is required: policy-only matching can accept a different
    # asset minted by the same policy.
    ENV['TREASURY_ADDRESS'].present?
  end
  helper_method :on_chain_mode?

  # Verify a pending deposit on-chain and credit it exactly once.
  # Returns the transfer's (possibly updated) status string.
  def settle_deposit(transfer)
    BeepDepositConfirmationService.new.call(transfer)
  end

  def settle_pending_deposits
    return unless on_chain_mode?

    @user.beep_chain_transfers.deposits.pending.limit(10).each { |transfer| settle_deposit(transfer) }
  end

  def settle_pending_withdrawals
    return unless on_chain_mode?

    @user.beep_chain_transfers
         .withdrawals
         .where(status: BeepWithdrawalConfirmationService::POLLABLE_STATUSES)
         .limit(10)
         .each { |transfer| BeepWithdrawalConfirmationService.new.call(transfer) }
  end

  # Real on-chain withdrawal: build/sign first, then atomically persist the
  # hash and debit immediately before submitting the treasury payout.
  def onchain_withdraw
    @user = current_user
    @account = @user.account

    unless @user.cardano_wallet_verified_at.present?
      flash[:alert] = 'Verify wallet ownership first — reconnect your wallet and sign the verification message.'
      return redirect_to wallet_path
    end

    token = approved_token_from_params
    unless token
      flash[:alert] = 'Choose an approved token to withdraw.'
      return redirect_to wallet_path
    end
    begin
      amount_units = token.parse_amount!(params[:amount])
    rescue TokenAmount::InvalidAmount => e
      flash[:alert] = e.message
      return redirect_to wallet_path
    end

    request_key = params[:request_key].to_s.strip.downcase
    unless request_key.match?(/\A[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/)
      flash[:alert] = 'This withdrawal request expired. Refresh the wallet page and try again.'
      return redirect_to wallet_path
    end

    existing = @user.beep_chain_transfers.withdrawals.find_by(request_key: request_key)
    if existing
      flash[:notice] = withdrawal_replay_message(existing)
      return redirect_to wallet_path
    end

    transfer = nil
    error = nil
    @account.with_lock do
      existing = @user.beep_chain_transfers.withdrawals.find_by(request_key: request_key)
      next if existing

      max_units = @account.token_balance_for(token).balance_units.to_i
      if amount_units > max_units
        error = "You can withdraw at most #{token.format_units(max_units)} #{token.ticker}."
        next
      end

      transfer = BeepChainTransfer.create!(
        user: @user,
        approved_token: token,
        direction: 'withdrawal',
        amount_beep: amount_units,
        amount_units: amount_units,
        status: 'pending',
        request_key: request_key,
        destination_address: @user.cardano_wallet_address
      )
    end

    if existing
      flash[:notice] = withdrawal_replay_message(existing)
      return redirect_to wallet_path
    end

    if error
      flash[:alert] = error
      return redirect_to wallet_path
    end

    begin
      CardanoTxTool.with_payout_lock do
        treasury_service = BlockfrostService.new
        available_treasury_units = treasury_service.get_token_balance(ENV['TREASURY_ADDRESS'], token)
        if available_treasury_units < amount_units
          raise CardanoTxTool::Error,
                "Treasury has insufficient #{token.ticker} right now. Please try again later."
        end
        treasury_lovelace = treasury_service.get_lovelace_balance(ENV['TREASURY_ADDRESS'])
        if treasury_lovelace < CardanoTxTool::MIN_PAYOUT_LOVELACE
          raise CardanoTxTool::Error,
                'Treasury has insufficient ADA for the payout fee and minimum output. Please try again later.'
        end

        treasury_token = CardanoTxTool.find_unit(ENV['TREASURY_ADDRESS'], token.asset_unit)
        if treasury_token[:quantity] < amount_units
          raise CardanoTxTool::Error, "Treasury has insufficient #{token.ticker} right now. Please try again later."
        end

        built = CardanoTxTool.build_payout(
          to_address: transfer.destination_address,
          unit: treasury_token[:unit],
          amount: amount_units
        )

        # Building and signing do not touch the game balance. Persist the
        # deterministic hash and debit under lock immediately before submit.
        @account.with_lock do
          balance = @account.token_balance_for(token)
          max_units = balance.balance_units.to_i
          if amount_units > max_units
            transfer.update!(status: 'failed', error_message: 'Game balance changed before the payout could be submitted.')
            raise CardanoTxTool::Error,
                  "Your available balance changed. You can now withdraw at most #{token.format_units(max_units)} #{token.ticker}."
          end

          balance.update!(balance_units: balance.balance_units.to_i - amount_units)
          Transaction.create!(
            account: @account,
            approved_token: token,
            amount_units: -amount_units,
            amount_cents: 0,
            type: 'AdjustmentTransaction',
            description: "On-chain withdrawal of #{token.format_units(amount_units)} #{token.ticker} to your Cardano wallet (processing).",
            status: 'completed'
          )
          transfer.update!(tx_hash: built[:tx_hash], status: 'submitting')
        end

        begin
          submitted_hash = CardanoTxTool.submit_payout(built[:signed_tx])
          raise CardanoTxTool::Error.new('Submitted transaction hash mismatch', stage: 'submit', tx_hash: built[:tx_hash]) unless submitted_hash == built[:tx_hash]
          transfer.update!(status: 'submitted')
        rescue CardanoTxTool::Error => e
          transfer.update_columns(
            tx_hash: e.tx_hash.presence || built[:tx_hash],
            status: 'unknown',
            error_message: "Ambiguous submission: #{e.message.to_s.first(180)}",
            updated_at: Time.current
          )
        end
      end

      BeepWithdrawalConfirmationJob.perform_later(transfer.id)
      if transfer.reload.status == 'unknown'
        flash[:alert] = "Your withdrawal submission is uncertain, but its transaction hash was saved and is being checked on-chain. Your balance stays debited until it resolves. Tx: #{transfer.tx_hash[0, 16]}…"
      else
        flash[:notice] = "Withdrawal submitted! #{token.format_units(amount_units)} #{token.ticker} is on its way to your wallet and is awaiting confirmation. Tx: #{transfer.tx_hash[0, 16]}…"
      end
  rescue TokenAmount::InvalidAmount => e
    flash[:alert] = e.message
    redirect_to wallet_path
  rescue StandardError => e
    Rails.logger.error "onchain_withdraw payout error for user #{@user.id}: #{e.class}: #{e.message}"
    transfer&.reload
    if transfer&.tx_hash.present?
      # A hash is persisted before submission starts. From this point onward
      # never auto-refund: the reconciler must decide from chain state.
      transfer.update_columns(
        status: 'unknown',
        error_message: "Withdrawal requires reconciliation: #{e.message.to_s.first(170)}",
        updated_at: Time.current
      )
      BeepWithdrawalConfirmationJob.perform_later(transfer.id)
      flash[:alert] = "Your withdrawal is being checked on-chain. Your balance stays debited until it resolves. Tx: #{transfer.tx_hash[0, 16]}…"
    else
      transfer&.update!(status: 'failed', error_message: e.message.to_s.first(200)) if transfer&.status == 'pending'
      flash[:alert] = "Withdrawal failed before submission. Your balance was not charged: #{e.message.to_s.first(120)}"
    end
    end

    redirect_to wallet_path
  end

  def withdrawal_replay_message(transfer)
    suffix = transfer.tx_hash.present? ? " Tx: #{transfer.tx_hash[0, 16]}…" : ''
    "This withdrawal was already received and was not charged twice. Status: #{transfer.status}.#{suffix}"
  end

  def approved_token_from_params
    value = params[:approved_token_id].presence || params[:token_id].presence || params[:asset_unit].presence
    return nil if value.blank?
    relation = ApprovedToken.enabled
    value.match?(/\A\d+\z/) ? relation.find_by(id: value) : relation.find_by(asset_unit: value.to_s.downcase)
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
        @on_chain_beep = on_chain_mode? ? 0 : service.get_beep_balance(@user.cardano_wallet_address)
        @selected_token_on_chain = @selected_token ? service.get_token_balance(@user.cardano_wallet_address, @selected_token) : 0
        if ENV['TREASURY_ADDRESS'].present?
          @treasury_token_units = @selected_token ? service.get_token_balance(ENV['TREASURY_ADDRESS'], @selected_token) : 0
          @treasury_lovelace = service.get_lovelace_balance(ENV['TREASURY_ADDRESS'])
        end
      rescue => e
        Rails.logger.error "Wallet info error: #{e.message}"
        @wallet_info = { ada_balance: 0.0, tokens: [], status: 'error' }
        @on_chain_beep = 0
        @selected_token_on_chain = 0
        @treasury_token_units = 0
        @treasury_lovelace = 0
      end
    else
      @wallet_info = nil
      @on_chain_beep = 0
      @selected_token_on_chain = 0
      @treasury_token_units = 0
      @treasury_lovelace = 0
    end

    # Treasury liquidity is relevant before a wallet is connected as well.
    # Keep this exact-unit/raw-lovelace read independent of the user's address.
    if @wallet_info.nil? && ENV['TREASURY_ADDRESS'].present? && ENV['BLOCKFROST_PROJECT_ID'].present?
      begin
        service = BlockfrostService.new
        @treasury_token_units = @selected_token ? service.get_token_balance(ENV['TREASURY_ADDRESS'], @selected_token) : 0
        @treasury_lovelace = service.get_lovelace_balance(ENV['TREASURY_ADDRESS'])
      rescue StandardError => e
        Rails.logger.error "Treasury wallet info error: #{e.message}"
      end
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
