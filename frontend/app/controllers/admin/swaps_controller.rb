class Admin::SwapsController < Admin::BaseController
  def index
    @search = params[:search].to_s.strip.first(200)
    @status = params[:status].to_s
    @payout_method = params[:payout_method].to_s
    raise ActionController::BadRequest, 'Invalid swap status' unless @status.blank? || CardanoSwap::STATUSES.include?(@status)
    raise ActionController::BadRequest, 'Invalid payout method' unless @payout_method.blank? || CardanoSwap::PAYOUT_METHODS.include?(@payout_method)

    @assets = SwapAsset.order(:ticker)
    @swaps = CardanoSwap.joins(:user, :swap_asset)
    @swaps = @swaps.where(status: @status) if @status.present?
    @swaps = @swaps.where(payout_method: @payout_method) if @payout_method.present?
    @swaps = @swaps.where(swap_asset_id: params[:swap_asset_id]) if params[:swap_asset_id].present?
    @swaps = @swaps.where(user_id: params[:user_id]) if params[:user_id].present?
    if @search.present?
      term = "%#{ActiveRecord::Base.sanitize_sql_like(@search)}%"
      @swaps = @swaps.where(
        'users.email LIKE :term OR users.username LIKE :term OR cardano_swaps.source_tx_hash LIKE :term OR cardano_swaps.payout_tx_hash LIKE :term OR swap_assets.ticker LIKE :term OR swap_assets.asset_unit LIKE :term',
        term: term
      )
    end
    @count = @swaps.count
    @totals = @swaps.group(:swap_asset_id, :status).sum(:amount_units)
    @asset_by_id = @assets.index_by(&:id)
    @beep_token = ApprovedToken.find_by(asset_unit: ENV['BEEP_ASSET_UNIT'])
    @swaps = @swaps.includes(:user, :swap_asset).order(id: :desc).page(params[:page]).per(25)
  end

  def show
    @swap = CardanoSwap.includes(:user, :swap_asset, :swap_quote).find(params[:id])
    @beep_token = ApprovedToken.find_by(asset_unit: ENV['BEEP_ASSET_UNIT'])
  end
end