set :branch, 'develop'
set :rails_env, :staging

set :linked_files, %w{config/unicorn.rb config/application.yml}

server 'staging.sportsbeep.com', user: 'apps', roles: [:app, :web, :db]