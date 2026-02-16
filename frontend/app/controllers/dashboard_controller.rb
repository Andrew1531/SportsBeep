class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
    @account = @user.account
    @recent_transactions = safe_collection { @account.transactions.order(created_at: :desc).limit(5) }
    @mlb_tickets = safe_collection { @user.mlb_tickets.includes(:contest).order(created_at: :desc).limit(5) }
    @nfl_tickets = safe_collection { @user.nfl_tickets.includes(:contest).order(created_at: :desc).limit(5) }
    load_wallet_info
  end

  def wallet
    @user = current_user
    @account = @user.account
    @transactions = safe_collection { @account.transactions.order(created_at: :desc).limit(20) }
    load_wallet_info
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

  private

  def safe_collection
    yield
  rescue NameError, NoMethodError
    []
  end

  def load_wallet_info
    if @user.cardano_wallet_address.present? && ENV['BLOCKFROST_PROJECT_ID'].present?
      begin
        service = BlockfrostService.new
        @wallet_info = service.get_address_info(@user.cardano_wallet_address)
      rescue => e
        Rails.logger.error "Wallet info error: #{e.message}"
        @wallet_info = { ada_balance: 0.0, tokens: [], status: 'error' }
      end
    else
      @wallet_info = nil
    end
  end
end
