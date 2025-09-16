# Puma configuration for Replit environment
# Bind to all interfaces and port 5000 for Replit proxy support

# Specifies the number of `workers` to boot in clustered mode.
workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
port ENV.fetch("PORT") { 5000 }

# Specifies the `environment` that Puma will run in.
environment ENV.fetch("RAILS_ENV") { "development" }

# Allow incoming requests from all hosts (required for Replit proxy)
bind "tcp://0.0.0.0:#{ENV.fetch('PORT') { 5000 }}"

# Specifies the number of `threads` per worker.
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Use the `preload_app!` method when specifying a `workers` number.
preload_app!

# Allow Puma to be restarted by `rails restart` command.
plugin :tmp_restart