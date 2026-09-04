class Admin::ApprovedTokensController < ApplicationController
  before_action :authenticate_administrator!
  before_action :set_token, only: [:edit, :update, :destroy]

  def index
    @approved_tokens = ApprovedToken.order(:ticker)
  end

  def new
    @approved_token = ApprovedToken.new(enabled: true, decimals: 0)
  end

  def create
    @approved_token = ApprovedToken.new(token_params)
    if @approved_token.save
      redirect_to admin_approved_tokens_path, notice: 'Approved token added.'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @approved_token.update(token_params)
      redirect_to admin_approved_tokens_path, notice: 'Approved token updated.'
    else
      render :edit
    end
  end

  def destroy
    @approved_token.update!(enabled: false)
    redirect_to admin_approved_tokens_path, notice: 'Token disabled.'
  end

  private

  def set_token
    @approved_token = ApprovedToken.find(params[:id])
  end

  def token_params
    params.require(:approved_token).permit(:asset_unit, :policy_id, :display_name, :ticker, :decimals, :enabled)
  end
end