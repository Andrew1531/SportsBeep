# SportsBeep Web Application

## Overview
This is a legacy Ruby on Rails sports betting/fantasy sports web application that has been successfully migrated to run in the Replit environment. The application includes a frontend Rails application and a separate backend timer API service.

## Current Status
- **Frontend Application**: ✅ Running successfully on port 5000
- **Backend Timer API**: ⚠️ Needs additional compatibility fixes for Ruby 3.2
- **Database**: ✅ Using SQLite3 for development
- **Deployment**: ✅ Configured for Replit autoscale deployment

## Project Structure
- `/frontend/` - Main Rails 6.1.7.10 web application (upgraded from Rails 4.1.0)
- `/backend/timerapi/` - Timer API service (Rails 4.0.3, needs migration)
- `/android/` - Native Android application

## Key Technical Changes Made
1. **Rails Upgrade**: Migrated from Rails 4.1.0 to Rails 6.1.7.10 for Ruby 3.2 compatibility
2. **Database Configuration**: Switched from MySQL to SQLite3 for development environment
3. **Host Configuration**: Configured to allow all hosts for Replit proxy support
4. **Dependency Management**: Removed problematic private gems and simplified dependencies
5. **Environment Fixes**: Added database adapter fixes and environment variable overrides

## How to Run
The application automatically starts with the configured workflow:
1. Frontend server runs on port 5000 with Puma
2. Database uses SQLite3 (no setup required)
3. Access via the Replit web preview

## Known Issues
- Database migrations need Rails version specification updates
- Backend timer API needs Ruby 3.2 compatibility fixes
- Some legacy gems removed (can be re-added individually as needed)

## Next Steps for Full Functionality
1. Fix remaining database migrations for full data model support
2. Migrate backend timer API to Rails 6+ for Ruby 3.2 compatibility  
3. Re-integrate removed gems as needed for specific features
4. Add proper error pages and user authentication flows