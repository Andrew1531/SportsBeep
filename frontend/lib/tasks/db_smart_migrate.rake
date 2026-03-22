namespace :db do
  desc 'Smart migrate: handles legacy DBs that were schema:loaded without recording migrations'
  task smart_migrate: :environment do
    connection = ActiveRecord::Base.connection

    # Ensure schema_migrations table exists
    connection.execute(<<~SQL)
      CREATE TABLE IF NOT EXISTS schema_migrations (
        version character varying NOT NULL,
        CONSTRAINT schema_migrations_pkey PRIMARY KEY (version)
      )
    SQL

    applied_versions = connection.execute("SELECT version FROM schema_migrations").map { |r| r['version'] }
    puts "Recorded migrations: #{applied_versions.size}"

    # Detect a schema:load situation: users table exists but the very first
    # devise migration is NOT recorded. This means the DB was built from
    # schema.rb (not migrations) and we must stamp all existing files first.
    first_migration = '20130821234157'
    users_table_exists = connection.table_exists?(:users)

    if users_table_exists && !applied_versions.include?(first_migration)
      puts "Detected schema:load database — stamping all existing migrations as applied..."

      migration_dir = Rails.root.join('db', 'migrate')
      all_versions = Dir[migration_dir.join('*.rb')].sort.map { |f| File.basename(f).split('_').first }

      all_versions.each do |version|
        next if applied_versions.include?(version)
        begin
          connection.execute("INSERT INTO schema_migrations (version) VALUES ('#{connection.quote_string(version)}')")
          puts "  Stamped: #{version}"
        rescue => e
          puts "  Already stamped #{version}: #{e.message}"
        end
      end

      puts "Stamping complete. Running db:migrate for any new migrations..."
    else
      puts "Normal migration run..."
    end

    Rake::Task['db:migrate'].invoke
    puts "Migration step complete."
  end
end
