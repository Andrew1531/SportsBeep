set :stage, :integration
set :branch, 'develop'
set :rails_env, :integration

set :linked_files, %w{config/database.yml config/unicorn.rb config/application.yml}

server '192.168.50.4', user: 'apps', roles: [:app, :web, :db]