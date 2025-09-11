require 'rubygems'

ENV["RAILS_ENV"] = 'test'

require File.expand_path("../../config/environment", __FILE__)

env = YAML.load File.read(Rails.root.join('spec/support/env.yml'))
env.each { |k, v| ENV[k] = v.to_s }

require 'avocado/rspec'
require 'capybara/rspec'
require 'rspec/rails'
require 'metova-rspec/all'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

Capybara.javascript_driver = :webkit
Capybara.default_wait_time = 10
Capybara.raise_server_errors = false

Sidekiq::Logging.logger = nil

ActiveRecord::Migration.maintain_test_schema!

module RSpec::Rails::ViewExampleGroup::ExampleMethods
  def _default_render_options
    if ::Rails.version >= "3.2"
      # pluck the handler, format, and locale out of, eg, posts/index.de.html.haml
      template, *components   = _default_file_to_render.split('.')

      version = components.find { |c| c == 'v2' } || 'v1'
      components = components.reject { |c| c == 'v2' }

      handler, format, locale = *components.reverse
      render_options = {:template => template}
      render_options[:handlers] = [handler] if handler
      render_options[:formats] = [format] if format
      render_options[:locales] = [locale] if locale
      render_options[:versions] = version

      render_options
    else
      {:template => _default_file_to_render}
    end
  end
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.fail_fast = ENV['FF']
  config.render_views = true
  config.order = 'random'
  config.include Capybara::DSL
  config.include Devise::TestHelpers, type: :controller

  config.before(:each) do
    Setting.create
    Fabricate :best_question, sport: 'Mlb', topic: Mlb::Stats::HOME_RUNS, text: 'Which team will hit the most home runs?'
    Fabricate :best_question, sport: 'Mlb', topic: Mlb::Stats::DOUBLES, text: 'Which team will give up the least doubles?'
    Fabricate :best_question, sport: 'Mlb', topic: Mlb::Stats::ERRORS, text: 'Which team will not make the most errors?', comparison: :less
    Fabricate :bust_question, sport: 'Mlb', topic: Mlb::Stats::STOLEN_BASES, text: 'Which team will steal the least?'
    Fabricate :bust_question, sport: 'Mlb', topic: Mlb::Stats::HITS, text: 'Which will not make the most hits?'
    Fabricate :bust_question, sport: 'Mlb', topic: Mlb::Stats::STRIKE_OUTS, text: 'Which team will strike out the most?'
    Fabricate :best_question, sport: 'Nfl', topic: Nfl::Stats::TURNOVERS, text: 'Which team will have the most turnovers?'
    Fabricate :best_question, sport: 'Nfl', topic: Nfl::Stats::PENALTIES, text: 'Which team will take the most penalties?'
    Fabricate :best_question, sport: 'Nfl', topic: Nfl::Stats::RED_ZONE_PCT, text: 'Which team will have the highest red zone percent?', comparison: :less
    Fabricate :bust_question, sport: 'Nfl', topic: Nfl::Stats::THIRD_DOWN_CV, text: 'Which team will not have the highest third down conversion rate?'
    Fabricate :bust_question, sport: 'Nfl', topic: Nfl::Stats::FOURTH_DOWN_CV, text: 'Which will not have the highest fourth down conversion rate?'
    Fabricate :bust_question, sport: 'Nfl', topic: Nfl::Stats::TOTAL_YDS, text: 'Which team will have the most total yards?'
  end

  config.around(:each) do |example|
    ENV['SPORT'] = nil
    ENV['SPORT'] = example.metadata[:sport] if example.metadata[:sport]
    example.run
  end

  config.before(:each) do
    ENV['SPORT'] ||= 'Mlb'
    version = example.metadata[:version] || 1
    request.headers['X-API-Version'] = version if defined?(request) && request
    view.stub(:current_sport) { ENV['SPORT'].constantize } if defined?(view)
  end

end

RSpec::Sidekiq.configure do |config|
  config.warn_when_jobs_not_processed_by_sidekiq = false
end