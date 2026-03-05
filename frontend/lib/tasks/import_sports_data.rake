namespace :sports do
  desc 'Import MLB teams from TheSportsDB'
  task import_mlb_teams: :environment do
    service = ThesportsdbService.new
    puts "Fetching MLB teams (searching each team individually)..."
    teams_data = service.fetch_mlb_teams

    puts "Found #{teams_data.length} MLB teams. Importing..."

    teams_data.each do |team_data|
      team = Mlb::Team.find_or_initialize_by(external_id: team_data['idTeam'])

      full_name = team_data['strTeam']
      parts = full_name.split(' ')
      market = parts[0..-2].join(' ') if parts.length > 1
      name = parts[-1] if parts.length > 0

      league = if team_data['strDivision']&.include?('American')
                 'AL'
               elsif team_data['strDivision']&.include?('National')
                 'NL'
               else
                 nil
               end

      team.assign_attributes(
        name: name || full_name,
        market: market || full_name,
        abbr: team_data['strTeamShort'],
        league: league,
        division: team_data['strDivision'],
        primary_color: team_data['strColour1'],
        secondary_color: team_data['strColour2']
      )

      if team.save
        puts "  ✓ #{team.market} #{team.name} (#{team.abbr}) [#{team.primary_color}]"
      else
        puts "  ✗ Failed: #{full_name}: #{team.errors.full_messages.join(', ')}"
      end
    end

    puts "MLB Teams imported: #{Mlb::Team.count}"
  end

  desc 'Import NFL teams from TheSportsDB'
  task import_nfl_teams: :environment do
    service = ThesportsdbService.new
    puts "Fetching NFL teams (searching each team individually)..."
    teams_data = service.fetch_nfl_teams

    puts "Found #{teams_data.length} NFL teams. Importing..."

    teams_data.each do |team_data|
      team = Nfl::Team.find_or_initialize_by(external_id: team_data['idTeam'])

      full_name = team_data['strTeam']
      parts = full_name.split(' ')
      market = parts[0..-2].join(' ') if parts.length > 1
      name = parts[-1] if parts.length > 0

      conference = team_data['strDivision']&.split(' ')&.first

      team.assign_attributes(
        name: name || full_name,
        market: market || full_name,
        abbr: team_data['strTeamShort'],
        league: 'NFL',
        conference: conference,
        division: team_data['strDivision'],
        primary_color: team_data['strColour1'],
        secondary_color: team_data['strColour2']
      )

      if team.save
        puts "  ✓ #{team.market} #{team.name} (#{team.abbr}) [#{team.primary_color}]"
      else
        puts "  ✗ Failed: #{full_name}: #{team.errors.full_messages.join(', ')}"
      end
    end

    puts "NFL Teams imported: #{Nfl::Team.count}"
  end

  desc 'Import MLB schedule for current season'
  task import_mlb_schedule: :environment do
    service = ThesportsdbService.new
    season = Date.today.year.to_s
    puts "Fetching MLB #{season} schedule..."
    events_data = service.fetch_mlb_schedule(season)

    puts "Found #{events_data.length} MLB events. Importing..."
    imported = 0
    skipped = 0

    events_data.each do |event_data|
      next unless event_data['strEvent']

      game = Mlb::Game.find_or_initialize_by(external_id: event_data['idEvent'])

      home_team = Mlb::Team.find_by(external_id: event_data['idHomeTeam'])
      away_team = Mlb::Team.find_by(external_id: event_data['idAwayTeam'])

      unless home_team && away_team
        puts "  ⚠ Skipping #{event_data['strEvent']} - team not in DB (home: #{event_data['idHomeTeam']}, away: #{event_data['idAwayTeam']})"
        skipped += 1
        next
      end

      start_time = parse_event_time(event_data)

      game.assign_attributes(
        home_team: home_team,
        away_team: away_team,
        start_time: start_time,
        status: event_data['strStatus'] || 'NS',
        bettable: false
      )

      if game.save
        imported += 1
        puts "  ✓ #{away_team.market} #{away_team.name} @ #{home_team.market} #{home_team.name} (#{event_data['dateEvent']})"
      else
        puts "  ✗ Failed: #{event_data['strEvent']}: #{game.errors.full_messages.join(', ')}"
      end
    end

    puts "MLB Games imported: #{imported}, skipped: #{skipped}"
  end

  desc 'Import NFL schedule for current season'
  task import_nfl_schedule: :environment do
    service = ThesportsdbService.new
    year = Date.today.year
    month = Date.today.month
    season = month >= 9 ? "#{year}-#{year + 1}" : "#{year - 1}-#{year}"
    puts "Fetching NFL #{season} schedule..."
    events_data = service.fetch_nfl_schedule(season)

    if events_data.empty?
      puts "No NFL games found for #{season} season."
      puts "NFL season may not have started yet or data is not available."
      next
    end

    puts "Found #{events_data.length} NFL events. Importing..."
    imported = 0
    skipped = 0

    events_data.each do |event_data|
      next unless event_data['strEvent']

      game = Nfl::Game.find_or_initialize_by(external_id: event_data['idEvent'])

      home_team = Nfl::Team.find_by(external_id: event_data['idHomeTeam'])
      away_team = Nfl::Team.find_by(external_id: event_data['idAwayTeam'])

      unless home_team && away_team
        puts "  ⚠ Skipping #{event_data['strEvent']} - team not in DB"
        skipped += 1
        next
      end

      start_time = parse_event_time(event_data)

      game.assign_attributes(
        home_team: home_team,
        away_team: away_team,
        start_time: start_time,
        status: event_data['strStatus'] || 'NS',
        bettable: false
      )

      if game.save
        imported += 1
        puts "  ✓ #{away_team.market} #{away_team.name} @ #{home_team.market} #{home_team.name} (#{event_data['dateEvent']})"
      else
        puts "  ✗ Failed: #{event_data['strEvent']}: #{game.errors.full_messages.join(', ')}"
      end
    end

    puts "NFL Games imported: #{imported}, skipped: #{skipped}"
  end

  desc 'Import MLB players for all teams'
  task import_mlb_players: :environment do
    service = ThesportsdbService.new
    teams = Mlb::Team.all

    if teams.empty?
      puts "No MLB teams in database. Run sports:import_mlb_teams first."
      return
    end

    puts "Importing players for #{teams.count} MLB teams..."
    total = 0

    teams.each do |team|
      next unless team.external_id.present?
      players_data = service.fetch_team_players(team.external_id)
      count = 0

      players_data.each do |player_data|
        player = Mlb::Player.find_or_initialize_by(external_id: player_data['idPlayer'])

        name_parts = (player_data['strPlayer'] || '').split(' ', 2)
        first_name = name_parts[0]
        last_name = name_parts[1] || ''

        player.assign_attributes(
          team: team,
          first_name: first_name,
          last_name: last_name,
          position: player_data['strPosition'],
          number: player_data['strNumber']&.to_i,
          status: player_data['strStatus'] || 'Active',
          headshot: player_data['strThumb'],
          on_current_roster: true
        )

        if player.save
          count += 1
        end
      end

      puts "  ✓ #{team.market} #{team.name}: #{count} players"
      total += count
      sleep(0.3)
    end

    puts "Total MLB players imported: #{total}"
  end

  desc 'Import NFL players for all teams'
  task import_nfl_players: :environment do
    service = ThesportsdbService.new
    teams = Nfl::Team.all

    if teams.empty?
      puts "No NFL teams in database. Run sports:import_nfl_teams first."
      return
    end

    puts "Importing players for #{teams.count} NFL teams..."
    total = 0

    teams.each do |team|
      next unless team.external_id.present?
      players_data = service.fetch_team_players(team.external_id)
      count = 0

      players_data.each do |player_data|
        player = Nfl::Player.find_or_initialize_by(external_id: player_data['idPlayer'])

        name_parts = (player_data['strPlayer'] || '').split(' ', 2)
        first_name = name_parts[0]
        last_name = name_parts[1] || ''

        player.assign_attributes(
          team: team,
          first_name: first_name,
          last_name: last_name,
          position: player_data['strPosition'],
          number: player_data['strNumber']&.to_i,
          status: player_data['strStatus'] || 'Active',
          headshot: player_data['strThumb'],
          on_current_roster: true
        )

        if player.save
          count += 1
        end
      end

      puts "  ✓ #{team.market} #{team.name}: #{count} players"
      total += count
      sleep(0.3)
    end

    puts "Total NFL players imported: #{total}"
  end

  desc 'Import all sports data (teams, schedules, and players)'
  task import_all: :environment do
    puts "=" * 60
    puts "IMPORTING ALL SPORTS DATA FROM THESPORTSDB"
    puts "=" * 60

    Rake::Task['sports:import_mlb_teams'].invoke
    puts ""
    Rake::Task['sports:import_nfl_teams'].invoke
    puts ""
    Rake::Task['sports:import_mlb_schedule'].invoke
    puts ""
    Rake::Task['sports:import_nfl_schedule'].invoke
    puts ""
    Rake::Task['sports:import_mlb_players'].invoke
    puts ""
    Rake::Task['sports:import_nfl_players'].invoke

    puts ""
    puts "=" * 60
    puts "IMPORT COMPLETED!"
    puts "=" * 60
    puts "MLB Teams:   #{Mlb::Team.count}"
    puts "NFL Teams:   #{Nfl::Team.count}"
    puts "MLB Games:   #{Mlb::Game.count}"
    puts "NFL Games:   #{Nfl::Game.count}"
    puts "MLB Players: #{Mlb::Player.count}"
    puts "NFL Players: #{Nfl::Player.count}"
  end
end

def parse_event_time(event_data)
  if event_data['strTimestamp'].present?
    DateTime.parse(event_data['strTimestamp'])
  elsif event_data['dateEvent'].present? && event_data['strTime'].present?
    DateTime.parse("#{event_data['dateEvent']} #{event_data['strTime']}")
  elsif event_data['dateEvent'].present?
    Date.parse(event_data['dateEvent']).to_datetime
  end
rescue ArgumentError
  nil
end
