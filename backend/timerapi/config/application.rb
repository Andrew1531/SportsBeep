require_relative "boot"

# Load logger explicitly for Ruby 3.2 compatibility
require 'logger'

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Timerapi
  class Application < Rails::Application
    # Initialize configuration defaults for Rails 7.0
    config.load_defaults 7.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Set Time.zone default to Eastern Time for Bloomfield, NJ
    config.time_zone = 'Eastern Time (US & Canada)'

    # API-only mode optimizations (timer API doesn't need views/assets)
    config.api_only = false  # Keep false for now to avoid issues

    # Allow all hosts for Replit proxy support
    config.hosts.clear
  end
end
