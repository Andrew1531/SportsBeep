class Admin::UsersController < Admin::BaseController

  before_action :set_promo_code

  def index
    @users = @promo_code ? @promo_code.users : User.all
    @count = @users.count
    @users = @users.page params[:page]
  end

  def show
    @user = User.find params[:id]
  end

  def update
    @user = User.find params[:id]
    @user.update(permitted_params)
    respond_with @user, action: :show
  end

  private

    def permitted_params
      params.require(:user).permit :password
    end

    def set_promo_code
      @promo_code = PromoCode.find_by id: params[:promo_code_id]
    end

end
