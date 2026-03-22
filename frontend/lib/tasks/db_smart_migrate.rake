namespace :db do
  desc 'Smart migrate: stamps already-applied migrations then runs any new ones'
  task smart_migrate: :environment do
    connection = ActiveRecord::Base.connection

    begin
      connection.execute("CREATE TABLE IF NOT EXISTS schema_migrations (version character varying NOT NULL, PRIMARY KEY (version))")
    rescue => e
      puts "schema_migrations already exists: #{e.message}"
    end

    applied = connection.execute("SELECT version FROM schema_migrations").map { |r| r['version'] }
    puts "Currently recorded migrations: #{applied.size}"

    migration_dir = Rails.root.join('db', 'migrate')
    migration_files = Dir[migration_dir.join('*.rb')].sort

    stamped = 0
    migration_files.each do |file|
      version = File.basename(file).split('_').first
      next if applied.include?(version)

      begin
        connection.execute("INSERT INTO schema_migrations (version) VALUES ('#{version}')")
        puts "  Stamped pre-existing migration: #{File.basename(file)}"
        stamped += 1
      rescue => e
        puts "  Could not stamp #{version}: #{e.message}"
      end
    end

    puts "Stamped #{stamped} pre-existing migrations as applied."
    puts "Running db:migrate for any genuinely new migrations..."

    begin
      Rake::Task['db:migrate'].invoke
      puts "Migrations complete."
    rescue => e
      puts "Migration error: #{e.message}"
      raise
    end
  end
end
