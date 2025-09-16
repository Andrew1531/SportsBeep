# Fix PostgreSQL adapter loading issue by ensuring SQLite3 is used in development
# This initializer runs before ActiveRecord initializes to override DATABASE_URL

if Rails.env.development?
  # Clear all PostgreSQL environment variables before ActiveRecord initializes
  ENV.delete('DATABASE_URL')
  ENV.delete('PGPORT')
  ENV.delete('PGPASSWORD') 
  ENV.delete('PGUSER')
  ENV.delete('PGDATABASE')
  ENV.delete('PGHOST')
  
  # Force Rails to use only database.yml configuration
  Rails.application.config.database_configuration = {
    'development' => {
      'adapter' => 'sqlite3',
      'database' => 'db/development.sqlite3',
      'pool' => 5,
      'timeout' => 5000
    }
  }
end