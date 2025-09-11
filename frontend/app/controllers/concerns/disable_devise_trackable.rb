module DisableDeviseTrackable
  extend ActiveSupport::Concern

  included do
    prepend_before_filter :disable_devise_trackable
  end

  private

    def disable_devise_trackable
      request.env["devise.skip_trackable"] = true
    end

end