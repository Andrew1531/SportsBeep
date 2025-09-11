namespace :deploy do

  desc 'Invoke a rake command on the remote server'
  task :rake!, [:command] => [:set_rails_env] do |task, args|
    on primary(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, args[:command]
        end
      end
    end
  end

end