class SportsbookController < ApplicationController
  before_action :authenticate_user!, only: [:place_wager, :my_bets]
  before_action :set_user_and_account

  def index
    @sport = params[:sport] || 'mlb'
    @games = fetch_games_with_odds(@sport)
    @open_wagers = @user ? @user.wagers.open.game_pending.recent.limit(5) : []
  end

  def place_wager
    clean_params = wager_params
    is_parlay = clean_params.delete(:is_parlay)
    parlay_legs_json = clean_params.delete(:parlay_legs)

    if is_parlay == 'true' && parlay_legs_json.present?
      clean_params[:bet_type] = 'parlay'
      clean_params[:selection_detail] = parlay_legs_json
    end

    @wager = @user.wagers.build(clean_params)

    success = false
    ActiveRecord::Base.transaction do
      if @wager.save
        @wager.debit_user_account!
        success = true
      end
    end

    if success
      redirect_to sportsbook_path(sport: @wager.sport), notice: "Wager placed! #{@wager.amount} $BEEP on #{@wager.selection} (#{@wager.odds_display})"
    else
      @sport = @wager.sport || 'mlb'
      @games = fetch_games_with_odds(@sport)
      @open_wagers = @user ? @user.wagers.open.game_pending.recent.limit(5) : []
      flash.now[:alert] = @wager.errors.full_messages.join(', ')
      render :index
    end
  end

  def my_bets
    @open_wagers = @user.wagers.open.game_pending.recent
    @settled_wagers = @user.wagers.settled.recent.limit(20)
    @total_wagered = @user.wagers.sum(:amount_cents)
    @total_won = @user.wagers.where(status: 'won').sum(:potential_payout_cents)
    @win_count = @user.wagers.where(status: 'won').count
    @loss_count = @user.wagers.where(status: 'lost').count
  end

  private

  def set_user_and_account
    @user = current_user
    @account = @user&.account
    @has_beep = @account&.balance_cents.to_i > 0
  end

  def wager_params
    params.require(:wager).permit(
      :sport, :league, :fixture_id, :game_id,
      :home_team, :away_team, :game_start_time,
      :bet_type, :selection, :selection_detail,
      :odds, :points, :amount_cents, :sportsbook,
      :is_parlay, :parlay_legs
    )
  end

  SPORTS_API_URL = 'http://localhost:3001/api/markets'.freeze

  def fetch_games_with_odds(sport_key)
    espn_games(sport_key)
  rescue StandardError => e
    Rails.logger.error "ESPN Sports API fetch error: #{e.message}"
    generate_matchups(sport_key)
  end

  # Fetch today's games straight from the ESPN scraper service.
  def espn_games(sport_key)
    require 'net/http'
    uri      = URI(SPORTS_API_URL)
    response = Net::HTTP.get_response(uri)
    raise "Sports API returned #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    data    = JSON.parse(response.body)
    markets = data['markets'] || []

    # Filter to the requested sport (MLB, NFL, etc.)
    sport_markets = markets.select { |m| m['sport']&.downcase == sport_key.downcase }
    return generate_matchups(sport_key) if sport_markets.empty?

    sport_markets.map { |m| espn_market_to_hash(m, sport_key) }
  end

  def espn_market_to_hash(m, sport_key)
    league   = sport_key.upcase
    odds_raw = m['odds']&.first || {}

    home_ml     = odds_raw['homeOdds'].present? ? odds_raw['homeOdds'].to_i : nil
    away_ml     = odds_raw['awayOdds'].present? ? odds_raw['awayOdds'].to_i : nil
    home_ml   ||= random_moneyline.first
    away_ml   ||= random_moneyline.last
    spread_pts  = odds_raw['spread'].present? ? odds_raw['spread'].to_f : random_spread(sport_key)
    total_pts   = odds_raw['overUnder'].present? ? odds_raw['overUnder'].to_f : random_total(sport_key)
    sportsbook  = odds_raw['provider'] || 'ESPN'

    game_state = m['gameState'] || 'pre'
    status     = { 'pre' => 'scheduled', 'in' => 'live', 'post' => 'final' }[game_state] || 'scheduled'
    is_live    = game_state == 'in'

    {
      fixture_id:  "ESPN-#{m['eventId']}",
      game_id:     m['eventId'].to_s,
      start_date:  m['scrapedAt'],
      home_team:   m['homeTeam'],
      away_team:   m['awayTeam'],
      sport:       sport_key,
      league:      league,
      status:      status,
      is_live:     is_live,
      clock:       m['clock'],
      period:      m['period'],
      detail:      m['detail'],
      home_score:  m['homeScore'],
      away_score:  m['awayScore'],
      odds: {
        moneyline: { home: home_ml, away: away_ml },
        spread:    { home: -110, away: -110, home_points: spread_pts, away_points: -spread_pts },
        total:     { over: -110, under: -110, points: total_pts },
        sportsbook: sportsbook,
        raw_odds_count: 3
      }
    }
  end

  def generate_matchups(sport_key)
    teams = case sport_key
            when 'mlb' then Mlb::Team.order('RANDOM()').limit(10).to_a
            when 'nfl' then Nfl::Team.order('RANDOM()').limit(8).to_a
            else []
            end

    if teams.length >= 2
      teams.each_slice(2).map do |pair|
        next unless pair.length == 2
        home = "#{pair[0].market} #{pair[0].name}"
        away = "#{pair[1].market} #{pair[1].name}"
        home_ml, away_ml = random_moneyline
        build_matchup(home, away, sport_key.upcase, sport_key, home_ml, away_ml, random_spread(sport_key), random_total(sport_key))
      end.compact
    else
      fallback_matchups(sport_key)
    end
  rescue StandardError
    fallback_matchups(sport_key)
  end

  def fallback_matchups(sport_key)
    case sport_key
    when 'mlb'
      [
        build_matchup('New York Yankees', 'Boston Red Sox',       'MLB', 'mlb', -175, 148,  -1.5, 8.5),
        build_matchup('Los Angeles Dodgers', 'San Francisco Giants', 'MLB', 'mlb', -160, 138, -1.5, 7.5),
        build_matchup('Houston Astros', 'Texas Rangers',          'MLB', 'mlb', -130, 110,  -1.5, 8.0),
        build_matchup('Atlanta Braves', 'New York Mets',          'MLB', 'mlb', -145, 122,  -1.5, 8.5),
        build_matchup('Chicago Cubs', 'Milwaukee Brewers',        'MLB', 'mlb',  115, -135,   1.5, 8.0),
        build_matchup('Philadelphia Phillies', 'Miami Marlins',   'MLB', 'mlb', -165, 140,  -1.5, 7.5),
      ]
    when 'nfl'
      [
        build_matchup('Kansas City Chiefs', 'Buffalo Bills',      'NFL', 'nfl', -155, 132,  -3.5, 47.5),
        build_matchup('Philadelphia Eagles', 'Dallas Cowboys',    'NFL', 'nfl', -135, 114,  -2.5, 46.0),
        build_matchup('San Francisco 49ers', 'Seattle Seahawks',  'NFL', 'nfl', -180, 152,  -4.5, 44.5),
        build_matchup('Baltimore Ravens', 'Cincinnati Bengals',   'NFL', 'nfl', -145, 122,  -3.0, 48.5),
        build_matchup('Miami Dolphins', 'New York Jets',          'NFL', 'nfl', -170, 144,  -4.0, 43.0),
      ]
    when 'nba'
      [
        build_matchup('Boston Celtics', 'Los Angeles Lakers',     'NBA', 'nba', -200, 170,  -5.5, 224.5),
        build_matchup('Denver Nuggets', 'Golden State Warriors',  'NBA', 'nba', -150, 130,  -3.5, 228.0),
        build_matchup('Milwaukee Bucks', 'Phoenix Suns',          'NBA', 'nba', -135, 115,  -2.5, 230.5),
        build_matchup('Oklahoma City Thunder', 'Minnesota Timberwolves', 'NBA', 'nba', -125, 105, -2.0, 222.0),
        build_matchup('Cleveland Cavaliers', 'Indiana Pacers',    'NBA', 'nba', -160, 136,  -4.0, 226.5),
      ]
    when 'nhl'
      [
        build_matchup('Edmonton Oilers', 'Toronto Maple Leafs',   'NHL', 'nhl', -130, 110,  -1.5, 6.5),
        build_matchup('Colorado Avalanche', 'Vegas Golden Knights','NHL', 'nhl',  105, -125,  1.5, 6.0),
        build_matchup('Florida Panthers', 'New York Rangers',     'NHL', 'nhl', -120, 100,  -1.5, 5.5),
        build_matchup('Dallas Stars', 'Winnipeg Jets',            'NHL', 'nhl', -140, 118,  -1.5, 5.5),
      ]
    else
      []
    end
  end

  def build_matchup(home, away, league, sport, home_ml, away_ml, spread_pts, total_pts)
    {
      fixture_id: SecureRandom.hex(6).upcase,
      game_id: "#{league}-#{SecureRandom.hex(3)}",
      start_date: (Time.now + rand(1..72).hours).iso8601,
      home_team: home,
      away_team: away,
      sport: sport,
      league: league,
      status: 'scheduled',
      is_live: false,
      odds: {
        moneyline: { home: home_ml, away: away_ml },
        spread: { home: -110, away: -110, home_points: spread_pts, away_points: -spread_pts },
        total: { over: -110, under: -110, points: total_pts },
        sportsbook: 'SportsBeep',
        raw_odds_count: 6
      }
    }
  end

  def random_moneyline
    favorite = rand(110..220)
    underdog = (favorite * 0.85).to_i
    [-favorite, underdog]
  end

  def random_spread(sport)
    case sport
    when 'mlb' then -(1.5)
    when 'nfl' then -(rand(1..7) + 0.5)
    when 'nba' then -(rand(1..8) + 0.5)
    when 'nhl' then -(1.5)
    else -1.5
    end
  end

  def random_total(sport)
    case sport
    when 'mlb' then (rand(70..95) / 10.0).round(1)
    when 'nfl' then (rand(400..540) / 10.0).round(1)
    when 'nba' then (rand(2100..2400) / 10.0).round(1)
    when 'nhl' then (rand(55..70) / 10.0).round(1)
    else 8.5
    end
  end
end
