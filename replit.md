# SportsBeep Web Application

## Overview
This is a legacy Ruby on Rails sports betting/fantasy sports web application being migrated to run in the Replit environment. The application includes a frontend Rails application and a separate backend timer API service.

## Current Status
- **Rails Server**: ✅ Running on port 5000 with Puma
- **Database**: ✅ SQLite3 configured and schema loaded
- **JavaScript Runtime**: ✅ Node.js 20 installed  
- **Asset Pipeline**: ✅ Sass/CSS compiling successfully (Rails 6 compatible)
- **Cardano Blockchain**: ✅ Integrated with Blockfrost API for crypto wallet support
- **Backend Timer API**: ❌ Needs Rails 6+ upgrade for Ruby 3.2 compatibility
- **Deployment**: ✅ Configured for Replit autoscale

## Project Structure
- `/frontend/` - Main Rails 6.1.7.10 web application (upgraded from Rails 4.1.0)
- `/backend/timerapi/` - Timer API service (Rails 4.0.3, needs migration)
- `/android/` - Native Android application

## Key Technical Changes Made
1. **Rails Upgrade**: Migrated from Rails 4.1.0 to Rails 6.1.7.10 for Ruby 3.2 compatibility
2. **Database Configuration**: Switched from MySQL master-slave to SQLite3 for all environments (development, staging, production)
3. **Host Configuration**: Configured to allow all hosts for Replit proxy support
4. **Dependency Management**: Removed problematic private gems and simplified dependencies
5. **Environment Fixes**: Added database adapter fixes and environment variable overrides
6. **Sass/Asset Pipeline**: Fixed Rails 6 Sass variable scoping by manually importing variables in each component file
7. **Deployment Setup**: Configured Puma web server for production autoscale deployment
8. **Cardano Integration**: Added Cardano wallet address field to user registration with Blockfrost API integration

## How to Run
The application automatically starts with the configured workflow:
1. Frontend server runs on port 5000 with Puma
2. Database uses SQLite3 (no setup required)
3. Access via the Replit web preview

## Social Media
- **Twitter**: @playsportsbeep
- **Facebook**: /sportsbeep
- **YouTube**: /channel/UCwcPSE82w0aYSspC8bZjlsg
- **Instagram**: /sportsbeep

## Cardano Blockchain Integration
- **Wallet Address Field**: Users can optionally provide their Cardano wallet address during sign up
- **BlockfrostService**: Service class for interacting with Cardano blockchain via Blockfrost API
- **API Key Management**: Secure storage of Blockfrost project ID in environment variables
- **Features**:
  - Retrieve wallet balances
  - Query stake pools
  - Validate Cardano addresses
  - Direct HTTPS API integration (uses Net::HTTP)
- **Database**: `cardano_wallet_address` field added to users table

## Known Issues

### Non-Critical
1. **Database Migrations**: 98 legacy migrations need Rails version declarations (e.g., `ActiveRecord::Migration[4.2]`)
2. **Backend Timer API**: Rails 4.0.3 cannot run on Ruby 3.2 - needs upgrade to Rails 6+
3. **Some Legacy Gems**: Removed during migration (can be re-added as needed)

## Deployment Configuration  
- **Type**: Autoscale (scales automatically based on traffic)
- **Build Command**: `bundle install --jobs 4 --retry 3 && RAILS_ENV=production bundle exec rake assets:precompile`
- **Run Command**: `RAILS_ENV=production bundle exec puma -C config/puma.rb`
- **Asset Compilation**: ✅ Precompiles during build (sassc 2.1.0, sprockets 3.7.5)
- **Database**: SQLite3 for all environments (development, staging, production)
- **Caching**: Memory store (64MB, no external dependencies)

## Next Steps for Full Functionality
1. Fix remaining database migrations for full data model support
2. Migrate backend timer API to Rails 6+ for Ruby 3.2 compatibility  
3. Re-integrate removed gems as needed for specific features
4. Add proper error pages and user authentication flows