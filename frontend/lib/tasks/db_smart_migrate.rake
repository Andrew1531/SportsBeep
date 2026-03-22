namespace :db do
  desc 'Smart migrate: safely handles existing production databases'
  task smart_migrate: :environment do
    connection = ActiveRecord::Base.connection

    # Step 1 — Make sure schema_migrations table exists
    connection.execute(<<~SQL)
      CREATE TABLE IF NOT EXISTS schema_migrations (
        version character varying NOT NULL,
        CONSTRAINT schema_migrations_pkey PRIMARY KEY (version)
      )
    SQL
    puts "schema_migrations table ready."

    # Step 2 — If the users table already exists, this is a pre-existing DB.
    # Stamp every migration file as already applied so db:migrate skips them.
    if connection.table_exists?(:users)
      puts "Existing database detected — stamping all legacy migrations..."
      migration_files = Dir[Rails.root.join('db', 'migrate', '*.rb')].sort
      stamped = 0
      migration_files.each do |file|
        version = File.basename(file).split('_').first
        connection.execute(
          "INSERT INTO schema_migrations (version) VALUES ('#{version}') ON CONFLICT DO NOTHING"
        )
        stamped += 1
      end
      puts "Stamped #{stamped} migrations as applied."
    else
      puts "Fresh database — running full migration..."
    end

    # Step 3 — Run db:migrate (will only apply genuinely new migrations)
    puts "Running db:migrate for any new migrations..."
    Rake::Task['db:migrate'].invoke
    puts "Done."
  end
end
