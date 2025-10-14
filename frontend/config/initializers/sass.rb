# Configure Sass to automatically prepend variables to all .scss files
Rails.application.config.assets.configure do |env|
  # Auto-prepend variables import to all SCSS files (except application.scss and _variables.scss itself)
  env.context_class.class_eval do
    def evaluate(path, options = {})
      if path.to_s.end_with?('.scss', '.sass') && 
         !path.to_s.include?('application.css.scss') && 
         !path.to_s.include?('_variables') &&
         !path.to_s.include?('_colors') &&
         !path.to_s.include?('_fonts')
        
        # Prepend imports for variables before compiling
        prepend_data = "@import 'variables';\n@import 'colors';\n"
        options[:data] = prepend_data + (options[:data] || File.read(path))
      end
      super(path, options)
    end
  end
end
