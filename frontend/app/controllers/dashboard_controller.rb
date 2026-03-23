class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
    @account = @user.account
    @recent_transactions = safe_collection { @account.transactions.order(created_at: :desc).limit(5) }
    @mlb_tickets = safe_collection { @user.mlb_tickets.includes(:contest).order(created_at: :desc).limit(5) }
    @nfl_tickets = safe_collection { @user.nfl_tickets.includes(:contest).order(created_at: :desc).limit(5) }
    load_wallet_info
    load_referral_info
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

  def sync_beep
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

    begin
      service = BlockfrostService.new
      on_chain_beep = service.get_beep_balance(@user.cardano_wallet_address)

      if on_chain_beep <= 0
        flash[:alert] = "No $BEEP tokens detected in your connected wallet. Make sure you have $BEEP tokens at the connected address."
        return redirect_to wallet_path
      end

      on_chain_cents = on_chain_beep * 100
      current_cents  = @account.balance_cents.to_i
      beep_synced    = (current_cents / 100).to_i

      if on_chain_beep <= beep_synced && current_cents > 0
        flash[:notice] = "Your platform balance already reflects your on-chain $BEEP holdings (#{on_chain_beep} $BEEP)."
        return redirect_to wallet_path
      end

      credit_cents = [on_chain_cents - current_cents, 0].max

      if credit_cents > 0
        @account.update!(balance_cents: current_cents + credit_cents)
        Transaction.create!(
          account:     @account,
          amount_cents: credit_cents,
          type:        'AdjustmentTransaction',
          description: "Synced #{on_chain_beep} $BEEP from Cardano wallet (#{@user.cardano_wallet_address.first(20)}...)",
          status:      'completed'
        )
        credited_beep = credit_cents / 100
        flash[:notice] = "#{credited_beep} $BEEP loaded to your platform account!"
      else
        flash[:notice] = "Balance already up to date (#{on_chain_beep} $BEEP on-chain)."
      end
    rescue => e
      Rails.logger.error "BEEP sync error for user #{@user.id}: #{e.message}"
      flash[:alert] = "Could not read wallet balance. Please try again shortly."
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
  end

  def load_referral_info
    @owned_promo = safe_collection { PromoCode.where(owner_user_id: @user.id) }.first
    @referral_count = @owned_promo ? @owned_promo.referral_count : 0
    @promo_earnings = @account.promo_earnings_dollars
    @referral_winnings = @account.referral_winnings_dollars
    @total_referral_earnings = @account.total_referral_earnings_dollars
  end
end
