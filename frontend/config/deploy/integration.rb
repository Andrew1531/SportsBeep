set :stage, :integration
set :branch, 'develop'
set :rails_env, :integration

set :linked_files, %w{config/database.yml config/unicorn.rb config/application.yml}

server 'integration.sportsbeep.com', user: 'apps', roles: [:app, :web, :db]