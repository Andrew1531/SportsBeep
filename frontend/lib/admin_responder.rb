class AdminResponder < ActionController::Responder
  include Responders::HttpCacheResponder
  include Responders::FlashResponder
  include Responders::LocationResponder

  def initialize(*)
    super
    @resources.prepend :admin
  end

  protected

    def navigation_behavior(error)
      if request.xhr?
        head (has_errors?) ? 400 : 200
      else
        super
      end
    end

end