class Api::SessionsController < Devise::SessionsController

  respond_to :json
  self.responder = ApiResponder

  include NoCSRFProtection
  include NoJSONRoot

  def create
    if current_user
      self.resource = current_user
      respond_with resource, status: :ok
    else
      self.resource = warden.authenticate! auth_options
      sign_in resource_name, resource
      respond_with resource, status: :created
    end
  end

  def destroy
    super
    self.resource.update(device_token: nil, platform: nil)
  end

  private

    def verified_request?
      request.content_type == "application/json" || super
    end

end