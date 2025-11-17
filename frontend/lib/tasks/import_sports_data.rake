namespace :sports do
  desc 'Import NFL teams from TheSportsDB'
  task import_nfl_teams: :environment do
    service = ThesportsdbService.new
    teams_data = service.fetch_nfl_teams
    
    puts "Importing #{teams_data.length} NFL teams..."
    
    teams_data.each do |team_data|
      team = Nfl::Team.find_or_initialize_by(external_id: team_data['idTeam'])
      
      # Extract city/market and team name (e.g., "Dallas Cowboys" -> market: "Dallas", name: "Cowboys")
      full_name = team_data['strTeam']
      parts = full_name.split(' ')
      market = parts[0..-2].join(' ') if parts.length > 1
      name = parts[-1] if parts.length > 0
      
      team.assign_attributes(
        name: name || full_name,
        market: market || full_name,
        abbr: team_data['strTeamShort'],
        league: 'NFL',
        conference: team_data['strDivision']&.split(' ')&.first, # Extract "NFC" from "NFC East"
        division: team_data['strDivision']
      )
      
      if team.save
        puts "✓ #{team.name}"
      else
        puts "✗ Failed to save #{team_data['strTeam']}: #{team.errors.full_messages.join(', ')}"
      end
    end
    
    puts "Completed importing NFL teams!"
  end
  
  desc 'Import MLB teams from TheSportsDB'
  task import_mlb_teams: :environment do
    service = ThesportsdbService.new
    teams_data = service.fetch_mlb_teams
    
    puts "Importing #{teams_data.length} MLB teams..."
    
    teams_data.each do |team_data|
      team = Mlb::Team.find_or_initialize_by(external_id: team_data['idTeam'])
      
      # Extract city/market and team name (e.g., "New York Yankees" -> market: "New York", name: "Yankees")
      full_name = team_data['strTeam']
      parts = full_name.split(' ')
      market = parts[0..-2].join(' ') if parts.length > 1
      name = parts[-1] if parts.length > 0
      
      # Determine league (AL/NL) from division
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
        division: team_data['strDivision']
      )
      
      if team.save
        puts "✓ #{team.name}"
      else
        puts "✗ Failed to save #{team_data['strTeam']}: #{team.errors.full_messages.join(', ')}"
      end
    end
    
    puts "Completed importing MLB teams!"
  end
  
  desc 'Import NFL schedule for current season'
  task import_nfl_schedule: :environment do
    service = ThesportsdbService.new
    events_data = service.fetch_nfl_schedule
    
    puts "Importing NFL schedule..."
    imported = 0
    
    events_data.each do |event_data|
      next unless event_data['strEvent'] # Skip if no event name
      
      game = Nfl::Game.find_or_initialize_by(external_id: event_data['idEvent'])
      
      home_team = Nfl::Team.find_by(external_id: event_data['idHomeTeam'])
      away_team = Nfl::Team.find_by(external_id: event_data['idAwayTeam'])
      
      unless home_team && away_team
        puts "⚠ Skipping #{event_data['strEvent']} - teams not found"
        next
      end
      
      # Parse start time from date and time
      start_time = begin
        if event_data['strTimestamp']
          DateTime.parse(event_data['strTimestamp'])
        elsif event_data['dateEvent'] && event_data['strTime']
          DateTime.parse("#{event_data['dateEvent']} #{event_data['strTime']}")
        elsif event_data['dateEvent']
          Date.parse(event_data['dateEvent']).to_datetime
        else
          nil
        end
      rescue ArgumentError
        nil
      end
      
      game.assign_attributes(
        home_team: home_team,
        away_team: away_team,
        start_time: start_time,
        status: event_data['strStatus'] || 'NS',
        bettable: true
      )
      
      if game.save
        imported += 1
        print "."
      else
        puts "\n✗ Failed to save #{event_data['strEvent']}: #{game.errors.full_messages.join(', ')}"
      end
    end
    
    puts "\nCompleted importing #{imported} NFL games!"
  end
  
  desc 'Import MLB schedule for current season'
  task import_mlb_schedule: :environment do
    service = ThesportsdbService.new
    events_data = service.fetch_mlb_schedule
    
    puts "Importing MLB schedule..."
    imported = 0
    
    events_data.each do |event_data|
      next unless event_data['strEvent'] # Skip if no event name
      
      game = Mlb::Game.find_or_initialize_by(external_id: event_data['idEvent'])
      
      home_team = Mlb::Team.find_by(external_id: event_data['idHomeTeam'])
      away_team = Mlb::Team.find_by(external_id: event_data['idAwayTeam'])
      
      unless home_team && away_team
        puts "⚠ Skipping #{event_data['strEvent']} - teams not found"
        next
      end
      
      # Parse start time from date and time
      start_time = begin
        if event_data['strTimestamp']
          DateTime.parse(event_data['strTimestamp'])
        elsif event_data['dateEvent'] && event_data['strTime']
          DateTime.parse("#{event_data['dateEvent']} #{event_data['strTime']}")
        elsif event_data['dateEvent']
          Date.parse(event_data['dateEvent']).to_datetime
        else
          nil
        end
      rescue ArgumentError
        nil
      end
      
      game.assign_attributes(
        home_team: home_team,
        away_team: away_team,
        start_time: start_time,
        status: event_data['strStatus'] || 'NS',
        bettable: true
      )
      
      if game.save
        imported += 1
        print "."
      else
        puts "\n✗ Failed to save #{event_data['strEvent']}: #{game.errors.full_messages.join(', ')}"
      end
    end
    
    puts "\nCompleted importing #{imported} MLB games!"
  end
  
  desc 'Import all sports data (teams and schedules)'
  task import_all: :environment do
    puts "=" * 60
    puts "IMPORTING ALL SPORTS DATA FROM THESPORTSDB"
    puts "=" * 60
    
    Rake::Task['sports:import_mlb_teams'].invoke
    puts "\n"
    Rake::Task['sports:import_nfl_teams'].invoke
    puts "\n"
    Rake::Task['sports:import_mlb_schedule'].invoke
    puts "\n"
    Rake::Task['sports:import_nfl_schedule'].invoke
    
    puts "\n" + "=" * 60
    puts "IMPORT COMPLETED!"
    puts "=" * 60
    puts "MLB Teams: #{Mlb::Team.count}"
    puts "NFL Teams: #{Nfl::Team.count}"
    puts "MLB Games: #{Mlb::Game.count}"
    puts "NFL Games: #{Nfl::Game.count}"
  end
end
