require 'net/http'
require 'json'

class OpticOddsService
  BASE_URL = 'https://api.opticodds.com/api/v3'

  SPORT_MAP = {
    'mlb' => 'baseball',
    'nfl' => 'football',
    'nba' => 'basketball',
    'nhl' => 'hockey'
  }.freeze

  LEAGUE_MAP = {
    'mlb' => 'MLB',
    'nfl' => 'NFL',
    'nba' => 'NBA',
    'nhl' => 'NHL'
  }.freeze

  def initialize
    @api_key = ENV['OPTICODDS_API_KEY']
  end

  def active_fixtures(sport_key = 'mlb', league: nil)
    sport = SPORT_MAP[sport_key] || sport_key
    league_id = league || LEAGUE_MAP[sport_key]

    params = { sport: sport }
    params[:league] = league_id if league_id

    response = make_request('/fixtures/active', params)
    return [] unless response && response['data']

    response['data'].map { |f| normalize_fixture(f) }
  rescue StandardError => e
    Rails.logger.error "OpticOdds active_fixtures error: #{e.message}"
    []
  end

  def fixture_odds(fixture_id, sportsbook: 'DraftKings', market: nil)
    params = { fixture_id: fixture_id, sportsbook: sportsbook, odds_format: 'AMERICAN' }
    params[:market] = market if market
    params[:is_main] = true

    response = make_request('/fixtures/odds', params)
    return nil unless response && response['data']

    data = response['data'].first
    return nil unless data

    normalize_odds(data)
  rescue StandardError => e
    Rails.logger.error "OpticOdds fixture_odds error: #{e.message}"
    nil
  end

  def fixtures_with_odds(sport_key = 'mlb', sportsbook: 'DraftKings')
    fixtures = active_fixtures(sport_key)
    return [] if fixtures.empty?

    fixtures.map do |fixture|
      odds = fixture_odds(fixture[:fixture_id], sportsbook: sportsbook)
      fixture.merge(odds: odds)
    end
  rescue StandardError => e
    Rails.logger.error "OpticOdds fixtures_with_odds error: #{e.message}"
    []
  end

  # Returns final scores for a completed fixture as
  # { home_score:, away_score: }, or nil if the game is not final / no data.
  def fixture_results(fixture_id)
    response = make_request('/fixtures/results', { fixture_id: fixture_id })
    return nil unless response && response['data']

    data = response['data'].is_a?(Array) ? response['data'].first : response['data']
    return nil unless data

    scores = data['scores'] || data['result'] || data
    home = scores.dig('home', 'total') || scores['home_score'] || data['home_score']
    away = scores.dig('away', 'total') || scores['away_score'] || data['away_score']
    status = (data['status'] || scores['status']).to_s.downcase

    return nil unless home && away
    return nil unless status.empty? || status.include?('final') || status.include?('complete') || status.include?('closed')

    { home_score: home.to_i, away_score: away.to_i }
  rescue StandardError => e
    Rails.logger.error "OpticOdds fixture_results error: #{e.message}"
    nil
  end

  def available_sports
    response = make_request('/sports/active')
    return [] unless response && response['data']

    response['data'].map { |s| { id: s['id'], name: s['name'] } }
  rescue StandardError => e
    Rails.logger.error "OpticOdds available_sports error: #{e.message}"
    []
  end

  def available_leagues(sport_key = nil)
    params = {}
    params[:sport] = SPORT_MAP[sport_key] || sport_key if sport_key

    response = make_request('/leagues', params)
    return [] unless response && response['data']

    response['data'].map { |l| { id: l['id'], name: l['name'], sport: l.dig('sport', 'name') } }
  rescue StandardError => e
    Rails.logger.error "OpticOdds available_leagues error: #{e.message}"
    []
  end

  def test_connection
    response = make_request('/sports')
    if response && response['data']
      { success: true, sports_count: response['data'].size, sports: response['data'].map { |s| s['name'] } }
    else
      { success: false, error: 'No data returned' }
    end
  rescue StandardError => e
    { success: false, error: e.message }
  end

  private

  def normalize_fixture(fixture)
    {
      fixture_id: fixture['id'],
      game_id: fixture['game_id'],
      start_date: fixture['start_date'],
      home_team: fixture['home_team_display'] || 'TBD',
      away_team: fixture['away_team_display'] || 'TBD',
      sport: fixture.dig('sport', 'name') || '',
      league: fixture.dig('league', 'name') || fixture.dig('league', 'id') || '',
      status: fixture['status'] || 'scheduled',
      is_live: fixture['is_live'] || false
    }
  end

  def normalize_odds(data)
    odds = data['odds'] || []

    moneyline = { home: nil, away: nil }
    spread = { home: nil, away: nil, home_points: nil, away_points: nil }
    total = { over: nil, under: nil, points: nil }

    odds.each do |odd|
      market = odd['market_name']&.downcase || ''
      selection = odd['selection']&.downcase || ''
      price = odd['price']

      case market
      when 'moneyline'
        if selection.include?('home') || selection == data['home_team_display']&.downcase
          moneyline[:home] = price
        elsif selection.include?('away') || selection == data['away_team_display']&.downcase
          moneyline[:away] = price
        else
          if moneyline[:home].nil?
            moneyline[:home] = price
          else
            moneyline[:away] = price
          end
        end
      when /spread|handicap/
        points = odd['selection_points']&.to_f || odd['handicap']&.to_f
        if selection.include?('home') || moneyline[:home].nil?
          spread[:home] = price
          spread[:home_points] = points
        else
          spread[:away] = price
          spread[:away_points] = points
        end
      when /total|over.*under/
        points = odd['selection_points']&.to_f || odd['handicap']&.to_f
        total[:points] = points if points
        if selection.include?('over')
          total[:over] = price
        elsif selection.include?('under')
          total[:under] = price
        end
      end
    end

    {
      moneyline: moneyline,
      spread: spread,
      total: total,
      sportsbook: odds.first&.dig('sportsbook') || 'DraftKings',
      raw_odds_count: odds.size
    }
  end

  def make_request(endpoint, params = {})
    uri = URI("#{BASE_URL}#{endpoint}")
    uri.query = URI.encode_www_form(params) unless params.empty?

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http.open_timeout = 15
    http.read_timeout = 15

    request = Net::HTTP::Get.new(uri)
    request['X-Api-Key'] = @api_key

    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)
    else
      Rails.logger.error "OpticOdds API Error: #{response.code} - #{response.body[0..500]}"
      nil
    end
  end
end
