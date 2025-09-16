DbReplicator.configure do |config|

  config.servers << DbReplicator::Localhost.new do |s|
    s.identifier = 'local'
    s.ip = 'localhost'
    s.app_path = '/workspace/sportsbeep-web'
    s.environment = 'development'
  end

  config.servers << DbReplicator::Server.new do |s|
    s.identifier = 'staging'
    s.ip = 'staging.sportsbeep.com'
    s.app_path = '/apps/sportsbeep/current'
    s.environment = 'staging'
    s.user = 'apps'
  end

end
