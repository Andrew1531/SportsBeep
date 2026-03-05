class RegistrationsController < Devise::RegistrationsController

  before_action :permit_parameters!, only: [:create, :update]
  prepend_before_action :logout_current_user, only: :new, if: :current_user

  def create
    build_resource(sign_up_params)
    resource.promo_code_text = params[:user][:promo_code] if params[:user][:promo_code].present?
    if resource.save
      sign_up(resource_name, resource)
      respond_with resource, location: after_sign_up_path_for(resource)
    else
      clean_up_passwords(resource)
      respond_with resource
    end
  end

  def after_sign_up_path_for(*)
    play_path
  end

  def after_update_path_for(*)
    user_path(resource)
  end

  private

    def permit_parameters!
      params[:user][:avatar_uuid] = SecureRandom.uuid if params[:user][:avatar]
      devise_parameter_sanitizer.permit(:account_update, keys: [:email, :username, :password, :current_password, :avatar, :avatar_uuid])
      devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :username, :password, :first_name, :last_name, :cardano_wallet_address])
    end

    def logout_current_user
      sign_out current_user
    end

end