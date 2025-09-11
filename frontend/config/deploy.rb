# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'sportsbeep'
set :deploy_user, 'apps'
set :repo_url, 'git@bitbucket.org:metova/sportsbeep-web.git'
set :deploy_to, "/apps/#{fetch(:application)}"
set :ssh_options, { forward_agent: true }
set :keep_releases, 3
set :pty, true

set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, -> { `cat .ruby-version` }

set :sidekiq_pid, -> { File.join(shared_path, 'pids', 'sidekiq.pid') }
set :unicorn_pid, -> { File.join(shared_path, 'pids', 'unicorn.pid') }
set :unicorn_config_path, -> { File.join(current_path, 'config', 'unicorn.rb') }

set :aws_access_key_id, -> { ENV['AWS_ACCESS_KEY_ID'] }
set :aws_secret_access_key, -> { ENV['AWS_SECRET_ACCESS_KEY'] }

namespace :deploy do
  desc 'Restart application'
  task :restart do
    invoke 'unicorn:restart'
  end

  after 'deploy:migrate', 'deploy:seed'
  after :publishing, :restart

  after 'deploy:seed', :import do
    Rake::Task['deploy:rake!'].invoke('teams:import')
  end

  after 'deploy:finished', :sync do
    Rake::Task['deploy:rake!'].invoke('sportsdata:sync')
  end

end
