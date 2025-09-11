class Admin::PromoCodesController < Admin::BaseController

  before_action :set_promo_code, only: [:show, :edit, :update, :destroy]

  def index
    @promo_codes = PromoCode.all.page params[:page]
  end

  def new
    @promo_code = PromoCode.new
  end

  def create
    @promo_code = PromoCode.create permitted_params
    respond_with @promo_code, location: -> { admin_promo_codes_path }
  end

  def show
  end

  def edit
  end

  def update
    @promo_code.update(permitted_params)
    respond_with @promo_code
  end

  def destroy
    @promo_code.destroy
    respond_with @promo_code
  end

  private

    def permitted_params
      params.require(:promo_code).permit :code, :note
    end

    def set_promo_code
      @promo_code = PromoCode.find(params[:id])
    end

end
