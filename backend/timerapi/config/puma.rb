# Puma configuration for Timer API on port 3001

# Specifies the `environment` that Puma will run in.
environment ENV.fetch("RAILS_ENV") { "development" }

# Specifies the number of `threads` per worker.
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Bind to port 3001 for Timer API
bind "tcp://0.0.0.0:#{ENV.fetch('PORT') { 3001 }}"

# Allow Puma to be restarted by `rails restart` command.
plugin :tmp_restart
