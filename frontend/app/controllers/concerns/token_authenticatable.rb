module TokenAuthenticatable
  extend ActiveSupport::Concern

  module ClassMethods
    def authenticated!(options = {})
      before_action :authenticate_user_from_token!, options
      before_action :authenticate_api_user!, options
    end

    def unauthenticated!
      skip_before_action :authenticate_user_from_token!
      skip_before_action :authenticate_api_user!
    end
  end

  private

    def authenticate_user_from_token!
      authenticate_or_request_with_http_token do |token, options|
        if user = User.find_by(authentication_token: token)
          sign_in(:api_user, user, store: false)
        end
      end
    end

end