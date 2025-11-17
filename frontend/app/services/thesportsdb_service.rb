require 'net/http'
require 'json'

class ThesportsdbService
  BASE_URL = 'https://www.thesportsdb.com/api/v1/json'
  
  # League IDs
  MLB_LEAGUE_ID = '4424'
  NFL_LEAGUE_ID = '4391'
  
  def initialize
    @api_key = ENV['THESPORTSDB_API_KEY'] || '1' # Use free key for real data (limited features)
  end
  
  # ========== NFL Methods ==========
  
  def fetch_nfl_teams
    fetch_teams(NFL_LEAGUE_ID)
  end
  
  def fetch_nfl_schedule(season = current_nfl_season)
    fetch_season_events(NFL_LEAGUE_ID, season)
  end
  
  def fetch_nfl_upcoming_games
    fetch_next_league_events(NFL_LEAGUE_ID)
  end
  
  # ========== MLB Methods ==========
  
  def fetch_mlb_teams
    fetch_teams(MLB_LEAGUE_ID)
  end
  
  def fetch_mlb_schedule(season = current_mlb_season)
    fetch_season_events(MLB_LEAGUE_ID, season)
  end
  
  def fetch_mlb_upcoming_games
    fetch_next_league_events(MLB_LEAGUE_ID)
  end
  
  # ========== Generic Methods ==========
  
  def fetch_teams(league_id)
    endpoint = "lookup_all_teams.php?id=#{league_id}"
    response = make_request(endpoint)
    response['teams'] || []
  end
  
  def fetch_season_events(league_id, season)
    endpoint = "eventsseason.php?id=#{league_id}&s=#{season}"
    response = make_request(endpoint)
    response['events'] || []
  end
  
  def fetch_next_league_events(league_id)
    endpoint = "eventsnextleague.php?id=#{league_id}"
    response = make_request(endpoint)
    response['events'] || []
  end
  
  def fetch_past_league_events(league_id)
    endpoint = "eventspastleague.php?id=#{league_id}"
    response = make_request(endpoint)
    response['events'] || []
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
  
  def fetch_team_players(team_id)
    endpoint = "lookup_all_players.php?id=#{team_id}"
    response = make_request(endpoint)
    response['player'] || []
  end
  
  private
  
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
    # NFL season spans two years (e.g., "2024-2025")
    year = Date.today.year
    month = Date.today.month
    
    # NFL season starts in September
    if month >= 9
      "#{year}-#{year + 1}"
    else
      "#{year - 1}-#{year}"
    end
  end
end
