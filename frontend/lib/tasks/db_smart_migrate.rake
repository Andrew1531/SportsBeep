namespace :db do
  desc 'Smart migrate: stamps legacy migrations, runs new ones properly'
  task smart_migrate: :environment do
    connection = ActiveRecord::Base.connection

    # Ensure schema_migrations table exists
    connection.execute(<<~SQL)
      CREATE TABLE IF NOT EXISTS schema_migrations (
        version character varying NOT NULL,
        CONSTRAINT schema_migrations_pkey PRIMARY KEY (version)
      )
    SQL
    puts "schema_migrations table ready."

    # Only stamp migrations from the original legacy Rails 4 codebase (before 2020).
    # Migrations from 2020+ are ones we added and must actually be run against the DB.
    LEGACY_CUTOFF = '20200101000000'

    if connection.table_exists?(:users)
      puts "Existing database detected — stamping legacy migrations (pre-2020) as applied..."
      migration_files = Dir[Rails.root.join('db', 'migrate', '*.rb')].sort
      stamped = 0
      migration_files.each do |file|
        version = File.basename(file).split('_').first
        next if version >= LEGACY_CUTOFF  # skip new migrations — let db:migrate run them
        connection.execute(
          "INSERT INTO schema_migrations (version) VALUES ('#{version}') ON CONFLICT DO NOTHING"
        )
        stamped += 1
      end
      puts "Stamped #{stamped} legacy migrations. New migrations will run via db:migrate."
    else
      puts "Fresh database — running full migration..."
    end

    # Run db:migrate — will only execute migrations NOT already in schema_migrations
    puts "Running db:migrate..."
    Rake::Task['db:migrate'].invoke
    puts "Migration complete."
  end
end
