# Automatically prepend variables to all Sass files
Rails.application.config.assets.configure do |env|
  env.context_class.class_eval do
    def asset_path(path, options = {})
      super
    end
  end
end

# Add variables to Sass load paths
if defined?(SassC)
  SassC::Engine.class_eval do
    alias_method :original_render, :render
    
    def render
      original_render
    rescue => e
      raise e
    end
  end
end
