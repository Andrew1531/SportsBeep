class Admin::UsersController < Admin::BaseController

  before_action :set_promo_code
  before_action :set_user, only: [:show, :edit, :update, :update_personal_info, :remove_personal_info]

  def index
    @users = @promo_code ? @promo_code.users : User.all
    
    # Search functionality
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @users = @users.where("email LIKE ? OR username LIKE ?", search_term, search_term)
    end
    
    # Sort by created_at descending by default
    @users = @users.order(created_at: :desc)
    
    @count = @users.count
    # Preload associations to avoid N+1 queries
    @users = @users.includes(:account, :promo_code, :tickets).page params[:page]
  end

  def show
    @user = User.includes(:account, :promo_code, tickets: { contest: { template: :game } }).find params[:id]
  end

  def edit
    @user.build_address unless @user.address
  end

  def update
    service.reset_password!(password_params[:password])
    redirect_to admin_user_path(@user), notice: "Password updated successfully for #{@user.email}"
  rescue AdminPersonalDataService::Error, ActiveRecord::RecordInvalid => error
    redirect_to admin_user_path(@user), alert: error.message
  end

  def update_personal_info
    service.correct!(personal_info_params)
    redirect_to admin_user_path(@user), notice: 'Personal information updated and audited.'
  rescue AdminPersonalDataService::Error, ActiveRecord::RecordInvalid => error
    @user.build_address unless @user.address
    flash.now[:danger] = error.message
    render :edit, status: :unprocessable_entity
  end

  def remove_personal_info
    service.remove!(
      admin_password: removal_params[:admin_password],
      confirmation: removal_params[:removal_confirmation]
    )
    redirect_to admin_user_path(@user), notice: 'Personal information removed. The account is disabled.'
  rescue AdminPersonalDataService::Error, ActiveRecord::RecordInvalid => error
    redirect_to edit_admin_user_path(@user), alert: error.message
  end

  private

    def set_user
      @user = User.find(params[:id])
    end

    def password_params
      params.require(:user).permit(:password, :reason)
    end

    def personal_info_params
      params.require(:user).permit(
        :email, :username, :first_name, :last_name,
        address_attributes: [:line_one, :line_two, :city, :state, :zip, :country]
      )
    end

    def removal_params
      params.require(:removal).permit(:admin_password, :removal_confirmation, :reason)
    end

    def service
      reason = params.dig(:user, :reason) || params.dig(:removal, :reason)
      AdminPersonalDataService.new(actor: current_administrator, user: @user, reason: reason)
    end

    def set_promo_code
      @promo_code = PromoCode.find_by id: params[:promo_code_id]
    end

end
