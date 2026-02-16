class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
    @account = @user.account
    @recent_transactions = safe_collection { @account.transactions.order(created_at: :desc).limit(5) }
    @mlb_tickets = safe_collection { @user.mlb_tickets.includes(:contest).order(created_at: :desc).limit(5) }
    @nfl_tickets = safe_collection { @user.nfl_tickets.includes(:contest).order(created_at: :desc).limit(5) }
  end

  def wallet
    @user = current_user
    @account = @user.account
    @transactions = safe_collection { @account.transactions.order(created_at: :desc).limit(20) }
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
end
