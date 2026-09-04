class Admin::SwapAssetsController < ApplicationController
  before_action :authenticate_administrator!
  before_action :set_asset, only: %i[edit update destroy]
  def index
    @swap_assets = SwapAsset.order(:ticker)
    @inventory = @swap_assets.index_with { |asset| CardanoSwap.where(swap_asset: asset).where.not(status: 'failed').sum(:amount_units) }
  end
  def new; @swap_asset = SwapAsset.new(enabled: true, decimals: 0); end
  def create
    @swap_asset = SwapAsset.new(asset_params)
    @swap_asset.save ? redirect_to(admin_swap_assets_path, notice: 'Swap asset added.') : render(:new)
  end
  def edit; end
  def update
    @swap_asset.update(asset_params) ? redirect_to(admin_swap_assets_path, notice: 'Swap asset updated.') : render(:edit)
  end
  def destroy
    @swap_asset.update!(enabled: false)
    redirect_to admin_swap_assets_path, notice: 'Swap asset disabled.'
  end
  private
  def set_asset; @swap_asset = SwapAsset.find(params[:id]); end
  def asset_params; params.require(:swap_asset).permit(:asset_unit, :policy_id, :ticker, :decimals, :beep_per_asset, :enabled); end
end