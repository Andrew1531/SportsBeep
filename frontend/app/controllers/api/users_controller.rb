class Api::UsersController < Api::BaseController

  def index
    @users = User.all
    respond_with @users
  end

  def show
    @user ||= User.find params[:id]
    respond_with @user
  end

  def update
    current_user.update permitted_params
    respond_with current_user
  end

  def me
    @user = current_user
    show
  end

  private

  def permitted_params
    params.require(:user).permit \
      :first_name, :last_name, :full_name, :email, :avatar, :password, :password_confirmation, :date_of_birth, :gender, :private, :location,
      { address_attributes: [:id, :line_one, :line_two, :city, :state, :zip, :country, :_destroy] },
      { facebook_auth_attributes: [:id, :uid, :email, :profile_picture, :auth_token, :_destroy] },
      { twitter_auth_attributes: [:id, :uid, :username, :auth_token, :auth_secret, :_destroy] }
  end

end