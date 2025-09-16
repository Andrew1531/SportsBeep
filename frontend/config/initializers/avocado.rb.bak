Avocado::Config.configure do |config|
  config.url = 'http://staging.sportsbeep.com/api-docs/specs'
  config.headers = ['Authorization', 'X-API-Version']
  config.document_if = -> { ENV['AVOCADO'] }
  config.yaml_path = Rails.root.join('..', '..', 'shared')
end