require 'net/http'
require 'json'

class ThesportsdbService
  BASE_URL = 'https://www.thesportsdb.com/api/v1/json'

  MLB_LEAGUE_ID = '4424'
  NFL_LEAGUE_ID = '4391'
  NBA_LEAGUE_ID = '4387'
  NHL_LEAGUE_ID = '4380'

  MLB_TEAMS = [
    'Arizona Diamondbacks', 'Atlanta Braves', 'Baltimore Orioles', 'Boston Red Sox',
    'Chicago Cubs', 'Chicago White Sox', 'Cincinnati Reds', 'Cleveland Guardians',
    'Colorado Rockies', 'Detroit Tigers', 'Houston Astros', 'Kansas City Royals',
    'Los Angeles Angels', 'Los Angeles Dodgers', 'Miami Marlins', 'Milwaukee Brewers',
    'Minnesota Twins', 'New York Mets', 'New York Yankees', 'Oakland Athletics',
    'Philadelphia Phillies', 'Pittsburgh Pirates', 'San Diego Padres', 'San Francisco Giants',
    'Seattle Mariners', 'St. Louis Cardinals', 'Tampa Bay Rays', 'Texas Rangers',
    'Toronto Blue Jays', 'Washington Nationals'
  ].freeze

  NFL_TEAMS = [
    'Arizona Cardinals', 'Atlanta Falcons', 'Baltimore Ravens', 'Buffalo Bills',
    'Carolina Panthers', 'Chicago Bears', 'Cincinnati Bengals', 'Cleveland Browns',
    'Dallas Cowboys', 'Denver Broncos', 'Detroit Lions', 'Green Bay Packers',
    'Houston Texans', 'Indianapolis Colts', 'Jacksonville Jaguars', 'Kansas City Chiefs',
    'Las Vegas Raiders', 'Los Angeles Chargers', 'Los Angeles Rams', 'Miami Dolphins',
    'Minnesota Vikings', 'New England Patriots', 'New Orleans Saints', 'New York Giants',
    'New York Jets', 'Philadelphia Eagles', 'Pittsburgh Steelers', 'San Francisco 49ers',
    'Seattle Seahawks', 'Tampa Bay Buccaneers', 'Tennessee Titans', 'Washington Commanders'
  ].freeze

  def initialize
    @api_key = ENV['THESPORTSDB_API_KEY'] || '3'
  end

  def fetch_mlb_teams
    search_teams_by_names(MLB_TEAMS)
  end

  def fetch_nfl_teams
    search_teams_by_names(NFL_TEAMS)
  end

  def search_team(name)
    endpoint = "searchteams.php?t=#{URI.encode_www_form_component(name)}"
    response = make_request(endpoint)
    teams = response['teams'] || []
    teams.first
  end

  def fetch_mlb_schedule(season = current_mlb_season)
    fetch_season_events(MLB_LEAGUE_ID, season)
  end

  def fetch_nfl_schedule(season = current_nfl_season)
    fetch_season_events(NFL_LEAGUE_ID, season)
  end

  def fetch_season_events(league_id, season)
    endpoint = "eventsseason.php?id=#{league_id}&s=#{season}"
    response = make_request(endpoint)
    response['events'] || []
  end

  def fetch_team_players(team_id)
    endpoint = "lookup_all_players.php?id=#{team_id}"
    response = make_request(endpoint)
    response['player'] || []
  end

  def fetch_event_details(event_id)
    endpoint = "lookupevent.php?id=#{event_id}"
    response = make_request(endpoint)
    response['events']&.first
  end

  def fetch_team_details(team_id)
    endpoint = "lookupteam.php?id=#{team_id}"
    response = make_request(endpoint)
    response['teams']&.first
  end

  private

  def search_teams_by_names(team_names)
    results = []
    team_names.each do |name|
      team_data = search_team(name)
      if team_data
        results << team_data
      else
        Rails.logger.warn "TheSportsDB: Could not find team '#{name}'"
      end
      sleep(0.3)
    end
    results
  end

  def make_request(endpoint)
    url = "#{BASE_URL}/#{@api_key}/#{endpoint}"
    uri = URI(url)

    response = Net::HTTP.get_response(uri)

    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)
    else
      Rails.logger.error "TheSportsDB API error: #{response.code} - #{response.message}"
      {}
    end
  rescue StandardError => e
    Rails.logger.error "TheSportsDB API request failed: #{e.message}"
    {}
  end

  def current_mlb_season
    Date.today.year.to_s
  end

  def current_nfl_season
    year = Date.today.year
    month = Date.today.month
    if month >= 9
      "#{year}-#{year + 1}"
    else
      "#{year - 1}-#{year}"
    end
  end
end
