class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
    @account = @user.account
    @recent_transactions = safe_collection { @account.transactions.order(created_at: :desc).limit(10) }
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

  def connect_cardano
    @user = current_user
    address = params[:cardano_address].to_s.strip
    valid = address.length > 50 && (
      address.start_with?('addr1') ||
      address.start_with?('addr_test1') ||
      address.start_with?('stake1') ||
      address.start_with?('stake_test1')
    )
    if valid
      @user.update(cardano_wallet_address: address)
      type = address.start_with?('stake') ? 'stake address' : 'payment address'
      flash[:notice] = "Cardano wallet connected (#{type})!"
    else
      flash[:alert] = "Invalid Cardano address. Use addr1... (payment) or stake1... (stake) format."
    end
    redirect_to safe_redirect_path
  end

  def disconnect_cardano
    current_user.update(cardano_wallet_address: nil)
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

  def withdraw_beep
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
