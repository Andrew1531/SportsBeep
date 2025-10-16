# Puma configuration for Replit environment

# Specifies the `environment` that Puma will run in.
environment ENV.fetch("RAILS_ENV") { "development" }

# Specifies the number of `threads` per worker.
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Bind to all interfaces and port 5000 for Replit proxy support
# Use ONLY bind (not port) to avoid worker conflicts
bind "tcp://0.0.0.0:#{ENV.fetch('PORT') { 5000 }}"

# Specifies the number of `workers` to boot in clustered mode (production only)
if ENV.fetch("RAILS_ENV") { "development" } == "production"
  workers ENV.fetch("WEB_CONCURRENCY") { 2 }
  
  # Preload app for memory efficiency
  preload_app!
  
  # Reconnect database after fork
  on_worker_boot do
    ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
  end
end

# Allow Puma to be restarted by `rails restart` command
plugin :tmp_restart
