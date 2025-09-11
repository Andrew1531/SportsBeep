class ApiResponder < ActionController::Responder
  include Responders::HttpCacheResponder

  def display(resource, options = {})
    options.delete :location
    super(resource, options)
  end

  def json_resource_errors
    { error: resource.errors.full_messages.first }
  end

  def to_json
    @options[:status] = :created if post?
    # return if http_cache? && http_cache!
    to_format
  end

  protected

    def http_cache?
      get? && persisted? && resourceful?
    end

    def http_cache!
      controller.fresh_when(resource)
    end

end