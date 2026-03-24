# SportsBeep Web Application

## Overview
This is a legacy Ruby on Rails sports betting/fantasy sports web application being migrated to run in the Replit environment. The application includes a frontend Rails application and a separate backend timer API service.

## Current Status
- **Rails Server**: ✅ Running on port 5000 with Puma
- **Database**: ✅ SQLite3 for development, PostgreSQL for production
- **JavaScript Runtime**: ✅ Node.js 20 installed  
- **Asset Pipeline**: ✅ Sass/CSS compiling successfully (Rails 6 compatible)
- **Cardano Blockchain**: ✅ Integrated with Blockfrost API for crypto wallet support
- **Sportsbook**: ✅ DraftKings-style with team logos, balance guard, bet slip
- **OpticOdds API**: ⚠️ Returns 403 (key permissions issue) — falls back to DB games with random odds
- **Balance Guard**: ✅ Inline warning + "Insufficient $BEEP" modal blocks overspending
- **Team Logos**: ✅ ESPN CDN logos displayed in sportsbook rows (MLB/NFL/NBA/NHL)
- **Fantasy Player Cards**: ✅ Smooth accordion expand — overflow:hidden bug fixed
- **Wallet Display**: ✅ Total In Play shown as whole $BEEP with amber warning if over on-chain
- **Backend Timer API**: ❌ Needs Rails 6+ upgrade for Ruby 3.2 compatibility
- **Deployment**: ✅ Configured for Replit autoscale with PostgreSQL

## Project Structure
- `/frontend/` - Main Rails 6.1.7.10 web application (upgraded from Rails 4.1.0)
- `/backend/timerapi/` - Timer API service (Rails 4.0.3, needs migration)
- `/android/` - Native Android application

## Key Technical Changes Made
1. **Rails Upgrade**: Migrated from Rails 4.1.0 to Rails 6.1.7.10 for Ruby 3.2 compatibility
2. **Database Configuration**: SQLite3 for development/test, PostgreSQL for production (autoscale compatible)
3. **Host Configuration**: Configured to allow all hosts for Replit proxy support
4. **Dependency Management**: Removed problematic private gems and simplified dependencies
5. **Environment Fixes**: Added database adapter fixes and environment variable overrides
6. **Sass/Asset Pipeline**: Fixed Rails 6 Sass variable scoping by manually importing variables in each component file
7. **Deployment Setup**: Configured Puma web server for production autoscale deployment with PostgreSQL
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
  - Retrieve wallet balances (ADA + tokens)
  - Query on-chain $BEEP token balance (`get_beep_balance`)
  - Sync $BEEP to platform account (`POST /wallet/sync_beep` → `DashboardController#sync_beep`)
  - Query stake pools
  - Validate Cardano addresses
  - Direct HTTPS API integration (uses Net::HTTP)
- **Database**: `cardano_wallet_address` field added to users table
- **BEEP Policy ID**: Set `BEEP_POLICY_ID` env var for exact token matching. If absent, falls back to hex-decoding asset name and looking for "BEEP"
- **Sync Logic**: Credits the DIFFERENCE between on-chain BEEP and current platform balance — prevents double-counting; allows top-ups when user acquires more BEEP

## Admin Portal Access
- **URL**: `/admin` (requires administrator authentication)
- **Login URL**: `/administrators/login`
- **Default Admin Account**:
  - Email: `getinked53@gmail.com`
  - Password: `$sb2025$`
  - Created manually via: `bundle exec rails runner "Administrator.create!(email: 'getinked53@gmail.com', password: '$sb2025$', password_confirmation: '$sb2025$')"`
- **Status**: ✅ Fully functional with comprehensive dashboard and management views
- **Features Implemented**:
  - ✅ Dashboard with statistics (users, games, contests, promo codes)
  - ✅ User Management (search, detailed user profiles, password reset)
  - ✅ Quick action buttons for all admin functions
  - ✅ System information display
  - ✅ Game Management (MLB/NFL) - Sport switching, statistics, game details
  - ✅ Promo Code Management - Full CRUD, usage analytics, top performing codes
  - ✅ Push Notifications - Send test notifications, notification types
  - ✅ Settings Page - Registration settings, system info, API configuration status

## Session — March 24, 2026
- **Team Logos in Sportsbook**: Replaced diagonal color-split panel with two stacked ESPN CDN logo images per game row. Added `.dk-logo-panel` / `.dk-logo-slot` / `.dk-team-logo-img` CSS. Fixed oversizing with `max-width/height: 36px` and `overflow: hidden`.
- **$BEEP Balance Guard (Sportsbook)**: Exposed `SB_BALANCE_CENTS` to page JS. `sbUpdatePayout()` shows inline red warning when amount > balance. `sbPlaceBet()` intercepts and shows "Insufficient $BEEP" modal with "Go to Wallet →" CTA. Server-side `must_have_sufficient_balance` validation remains as safety net.
- **Wallet "Total In Play" Fix**: Changed display from `200.00` decimal format to whole integer with `$BEEP` label. Card turns amber with `!` badge and sync hint when in-play exceeds on-chain balance.
- **Fantasy Player Card Accordion**: Fixed `overflow: hidden` on `.player-card` that was clipping BEST/BUST buttons. Replaced `display: none/flex` toggle with CSS grid accordion (`grid-template-rows: 0fr → 1fr`, 220ms ease). Added `.expanded` border glow, auto-scroll after animation, bigger tap targets.
- **Sportsbook 500 Error Fix**: `dashboard_path` in Buy BEEP modal was undefined in non-admin context — corrected to `wallet_path`.

## Recent Fixes
- **Devise Parameter Sanitizer**: Updated from Rails 4 `.for()` syntax to Rails 6 `.permit()` syntax for user registration
- **User Sign-up**: Now accepts username, email, password, first_name, last_name, and cardano_wallet_address
- **Landing Page About Section**: Updated with new Cardano blockchain positioning, $BEEP token information, Tech Stack details, and Our Mission statement
- **Database Migrations**: ✅ Fixed all 98 legacy migrations to specify Rails version (`ActiveRecord::Migration[4.2]`)
- **Production Deployment**: ✅ Added database migrations to build step to ensure production database is initialized
- **Landing Page HTML5 Tags**: ✅ Replaced `<header>` tags with `<h2>` tags to fix rendering issues in Chrome
- **Production Database**: ✅ Configured to use PostgreSQL instead of SQLite3 for persistence on autoscale
- **Legacy Migration Data Updates**: ✅ Fixed 6 migrations - replaced ActiveRecord calls with raw SQL to avoid circular dependencies
- **Admin Sessions Controller**: Fixed after_sign_in redirect to properly route to admin dashboard
- **Admin Base Controller**: Removed missing Pundit and Responders dependencies, fixed set_current_sport method
- **Admin User Management**: Built comprehensive user list with search, detailed user profiles with account/activity stats, N+1 query optimization with preloading
- **Sportsbook UI Redesign**: Complete rebuild to DraftKings/FanDuel style — dark background (#0b0e14), table-grid odds layout with SPREAD/TOTAL/MONEYLINE columns, team color indicator bars, compact game rows, slide-up bet slip panel, green accent (#00c853) for odds/CTA buttons

## Daily Fantasy Sports (DFS) — Best/Bust Format
- **URL**: `/fantasy` (requires user authentication)
- **My Entries**: `/fantasy/my-entries`
- **Game Detail**: `/fantasy/game/:id?sport=mlb|nfl`
- **Enter Contest**: `POST /fantasy/enter` (contest_id, best_player_ids[], bust_player_ids[])
- **Status**: ✅ Fully playable — 45 contests live across 15 MLB games
- **Best/Bust Game Format**:
  - Pick **3 BEST** players you think will perform the best today
  - Pick **3 BUST** players you think will underperform today
  - Winners determined by actual stat performance
- **Features**:
  - Browse upcoming MLB games with team-colored cards
  - Game detail page with tabbed UI: "Pick Players" + "Contests"
  - Player cards showing projected stats (AVG/HR/RBI for batters, ERA/K/IP for pitchers)
  - Click player → BEST 🔥 or BUST 💀 pick buttons appear
  - Floating picks panel (bottom): 6 slots (3 green BEST + 3 red BUST)
  - Team filter: All / Away team / Home team
  - Contest selection: 3 tiers per game (Free 200 $BEEP / Starter 500 $BEEP / Pro 2500 $BEEP)
  - Entry deducts BEEP from account balance (free contest available)
  - Submit button enables only when contest selected + all 6 picks made
- **Data Model**: Ticket → TicketPlayer (position: 'best'|'bust')
- **Seed Data**: `rake fantasy:setup` — creates pools, templates (skip_question_validation), contests
- **Pool#name**: Virtual method — "Free — 200 $BEEP Prize Pool" or "10.0 $BEEP Entry — 500 $BEEP Prize Pool"

## Known Issues

### Non-Critical
1. **Backend Timer API**: Rails 4.0.3 cannot run on Ruby 3.2 - needs upgrade to Rails 6+
2. **Some Legacy Gems**: Removed during migration (can be re-added as needed)

## Deployment Configuration  
- **Type**: Autoscale (scales automatically based on traffic)
- **Build Command**: `bundle install --jobs 4 --retry 3 && cd frontend && RAILS_ENV=production bundle exec rake assets:precompile`
- **Run Command**: `cd frontend && RAILS_ENV=production bundle exec rake db:migrate && RAILS_ENV=production bundle exec puma -C config/puma.rb`
- **Timezone**: Eastern Time (US & Canada) - Bloomfield, NJ
- **Asset Compilation**: ✅ Precompiles during build (sassc 2.1.0, sprockets 3.7.5)
- **Database**: 
  - Development/Test: SQLite3
  - Production: PostgreSQL (Replit managed, persistent across deployments)
- **Database Migrations**: ✅ Runs `db:migrate` automatically at runtime
- **Caching**: Memory store (64MB, no external dependencies)
- **Production Ready**: ✅ Timezone data (tzinfo-data) installed and configured

## Backend Timer API Status
**Current State**: Rails 4.0.3 → 6.1.7.10 upgrade in progress
- **Issue**: Rails 6.1 has compatibility issues with Ruby 3.2 (Logger::Severity errors)
- **Solution**: Requires Rails 7.x or custom logger configuration
- **Endpoints**: 
  - `GET /ticket_timer_states_get/:ticket_number/:seconds/:precision` - Generate encrypted timer states
  - `GET /ticket_question_answer_set/:ticket_number/:question_number/:answer/:timer_state_text` - Record answer with timestamp

## Android App Status
**Current State**: Needs modernization
- **Build System**: Gradle 1.0.1 (very outdated, needs update to 8.x+)
- **Dependencies**: Retrofit 1.6.1, OkHttp 1.6.0, Play Services 6.1.71 (all need updates)
- **API Integration**: Connects to Timer API for game timing functionality

## TheSportsDB Integration (Ready to Use)
- **Service**: `app/services/thesportsdb_service.rb` - Complete API wrapper for MLB/NFL data
- **Rake Tasks**: `lib/tasks/import_sports_data.rake` - Import teams and schedules
- **Status**: ⏸️ Awaiting premium API key ($9/month required for real data)
- **Environment Variable**: `THESPORTSDB_API_KEY` (add via Replit Secrets)
- **Available Commands**:
  - `rake sports:import_mlb_teams` - Import all 30 MLB teams
  - `rake sports:import_nfl_teams` - Import all 32 NFL teams
  - `rake sports:import_mlb_schedule` - Import current MLB season schedule
  - `rake sports:import_nfl_schedule` - Import current NFL season schedule
  - `rake sports:import_all` - Import everything at once
- **Note**: Free API has been restricted. Premium key available at https://www.thesportsdb.com/free_sports_api

## Development Roadmap (18 Tasks)
**Completed:**
- ✅ Task 1: Admin Dashboard with statistics and quick actions
- ✅ Task 2: Admin User Management with search and detailed views
- ✅ Task 3: Admin Game Management (MLB/NFL) with sport switching and statistics
- ✅ Task 4: Admin Promo Code Management with CRUD and usage analytics
- ✅ Task 5: Admin Push Notifications interface
- ✅ Task 6: Admin Settings Page with system info and API status

**Pending:**
- 🔨 Tasks 7-10: Legal/educational pages (How to Play, ToS, Refund, Privacy)
- 🔨 Tasks 11-14: User features (Dashboard, Wallet, Transactions, Promo redemption)
- 🔨 Tasks 15-18: Game features (Selection, Team building, Contest entry, Leaderboards)

## Next Steps for Full Functionality
1. **Obtain TheSportsDB API key** - Sign up for premium to import real MLB/NFL data
2. Upgrade Timer API to Rails 7.x for Ruby 3.2 compatibility
3. Complete remaining admin features (Tasks 3-6)
4. Build legal/educational content pages (Tasks 7-10)
5. Implement user-facing features (Tasks 11-18)
6. Modernize Android app build system and dependencies