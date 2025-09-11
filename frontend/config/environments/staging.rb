require Rails.root.join('config', 'environments', 'production')

SportsbeepWeb::Application.configure do
  # Setup Elasticache
  elasticache = Dalli::ElastiCache.new 'staging.852vy4.cfg.use1.cache.amazonaws.com:11211'
  config.cache_store = :dalli_store, elasticache.servers, { expires_in: 3.days, compress: true }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  config.action_mailer.default_url_options = { host: 'staging.sportsbeep.com' }

  config.action_mailer.smtp_settings = {
    address: "smtp.mandrillapp.com",
    port: 587,
    enable_starttls_auto: true,
    user_name: "admin@sportsbeep.com",
    password: "y-KvtsoHhC6ayMPuBVu0yg",
    authentication: 'login',
    domain: 'staging.sportsbeep.com'
  }

end
