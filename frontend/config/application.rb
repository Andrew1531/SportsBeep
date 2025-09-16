require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
require 'base64'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module SportsbeepWeb
  class Application < Rails::Application

    config.log_tags = [
      -> (req) do
        "V#{req.headers.fetch('X-API-Version', 1)}"
      end
    ]

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.assets.paths << Rails.root.join('vendor', 'assets', 'fonts')
    config.assets.precompile << /\.(?:svg|eot|woff|ttf)$/

    config.active_record.default_timezone = :utc
    config.active_record.maintain_test_schema = true
    # config.responders.flash_keys = [:success, :danger]

    config.middleware.use Rack::Deflater

    # config.versioncake.supported_version_numbers = (1..2)
    # config.versioncake.extraction_strategy = :http_header
    # config.versioncake.default_version = 1

    config.autoload_paths += %W(
      #{config.root}/app/models/transactions
      #{config.root}/app/services/callbacks
      #{config.root}/lib
      #{config.root}/lib/middleware
    )

    initializer :require_sportsdata do |app|
      %w(mlb nfl).each do |sport|
        path = app.root.join('app', 'services', 'sportsdata', sport)
        Dir[path.join('**/*.rb')].each { |file| require file }
      end
    end

    config.generators do |g|
      g.test_framework :rspec, fixture: true, routing_specs: false, helper_specs: false
      g.fixture_replacement :fabrication
    end

  end
end
