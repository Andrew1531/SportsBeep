class Admin::UsersController < Admin::BaseController

  before_action :set_promo_code

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
    @user = User.includes(:account, :promo_code, :tickets).find params[:id]
  end

  def update
    @user = User.find params[:id]
    
    if permitted_params[:password].present?
      if @user.update(permitted_params)
        flash[:success] = "Password updated successfully for #{@user.email}"
      else
        flash[:danger] = "Failed to update password: #{@user.errors.full_messages.join(', ')}"
      end
    else
      flash[:warning] = "Password cannot be blank"
    end
    
    respond_with @user, action: :show, location: admin_user_path(@user)
  end

  private

    def permitted_params
      params.require(:user).permit :password
    end

    def set_promo_code
      @promo_code = PromoCode.find_by id: params[:promo_code_id]
    end

end
