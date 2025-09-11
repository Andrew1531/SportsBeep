class Api::BaseController < ApplicationController
  respond_to :json
  self.responder = ApiResponder

  include NoCSRFProtection
  include NoJSONRoot
  include JSONErrorHandling
  include TokenAuthenticatable
  include Paginable
  include Pundit
  include DisableDeviseTrackable

  authenticated!

  def current_user
    current_api_user
  end

  def current_sport
    _sport
  end

  helper_method :current_user
  helper_method :current_sport

end