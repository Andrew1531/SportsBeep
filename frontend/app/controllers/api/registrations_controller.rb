class Api::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  self.responder = ApiResponder

  include NoCSRFProtection
  include NoJSONRoot
  include TokenAuthenticatable
  include JSONErrorHandling

  prepend_before_action :authenticate_user_from_token!, only: :update
  before_action :authenticate_api_user!, only: :update

  def create
    build_resource(permitted_params)
    resource.promo_code_text = params[:api_user][:promo_code]
    if resource.save
      sign_up(resource_name, resource)
      respond_with resource, status: :created
    else
      clean_up_passwords(resource)
      respond_with resource, status: :created
    end
  end

  def update
    self.resource = current_api_user
    resource.avatar_uuid = SecureRandom.uuid if permitted_params[:avatar]
    resource.update(permitted_params)
    respond_with resource, responder: DisplayResourceOnPUTResponder
  end

  private

    def permitted_params
      params.require(:api_user).permit \
        :email, :password, :current_password, :password_confirmation,
        :username, :first_name, :last_name, :device_token, :platform, :avatar, :remove_avatar,
        { facebook_auth_attributes: [:id, :uid, :email, :profile_picture, :auth_token] },
        { twitter_auth_attributes: [:id, :uid, :username, :auth_token, :auth_secret] },
        { instagram_auth_attributes: [:id, :uid, :username, :auth_token, :profile_picture, :email] }
    end

end