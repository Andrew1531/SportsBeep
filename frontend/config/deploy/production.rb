set :branch, 'production'
set :rails_env, :production
set :linked_files, %w{config/unicorn.rb config/application.yml}
set :aws_autoscale_instance_size, 'm1.large'

autoscale 'production', user: 'apps', roles: [:app, :web, :db]

# server '54.86.160.248', user: 'apps', roles: [:app, :web, :db]