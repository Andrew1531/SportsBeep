class Admin::PromoCodesController < Admin::BaseController

  before_action :set_promo_code, only: [:show, :edit, :update, :destroy]

  def index
    @promo_codes = PromoCode.includes(:users).order(created_at: :desc).page params[:page]
  end

  def new
    @promo_code = PromoCode.new
  end

  def create
    @promo_code = PromoCode.new(permitted_params)
    if @promo_code.save
      flash[:success] = "Promo code '#{@promo_code.code}' created successfully!"
      redirect_to admin_promo_codes_path
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @promo_code.update(permitted_params)
      flash[:success] = "Promo code updated successfully!"
      redirect_to admin_promo_code_path(@promo_code)
    else
      render :edit
    end
  end

  def destroy
    code = @promo_code.code
    @promo_code.destroy
    flash[:success] = "Promo code '#{code}' deleted successfully!"
    redirect_to admin_promo_codes_path
  end

  private

    def permitted_params
      params.require(:promo_code).permit :code, :note
    end

    def set_promo_code
      @promo_code = PromoCode.includes(:users).find(params[:id])
    end

end
