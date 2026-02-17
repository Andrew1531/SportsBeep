class SportsbookController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_and_account

  def index
    @sport = params[:sport] || 'mlb'
    @games = fetch_games_with_odds(@sport)
    @open_wagers = @user.wagers.open.recent.limit(5) rescue []
  end

  def place_wager
    @wager = @user.wagers.build(wager_params)

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
      @open_wagers = @user.wagers.open.recent.limit(5) rescue []
      flash.now[:alert] = @wager.errors.full_messages.join(', ')
      render :index
    end
  end

  def my_bets
    @open_wagers = @user.wagers.open.recent
    @settled_wagers = @user.wagers.settled.recent.limit(20)
    @total_wagered = @user.wagers.sum(:amount_cents)
    @total_won = @user.wagers.where(status: 'won').sum(:potential_payout_cents)
    @win_count = @user.wagers.where(status: 'won').count
    @loss_count = @user.wagers.where(status: 'lost').count
  end

  private

  def set_user_and_account
    @user = current_user
    @account = @user.account
    @has_beep = @account.balance_cents > 0 rescue false
  end

  def wager_params
    params.require(:wager).permit(
      :sport, :league, :fixture_id, :game_id,
      :home_team, :away_team, :game_start_time,
      :bet_type, :selection, :selection_detail,
      :odds, :points, :amount_cents, :sportsbook
    )
  end

  def fetch_games_with_odds(sport_key)
    service = OpticOddsService.new
    games = service.fixtures_with_odds(sport_key)

    if games.empty?
      sample_games(sport_key)
    else
      games
    end
  rescue StandardError => e
    Rails.logger.error "Sportsbook fetch error: #{e.message}"
    sample_games(sport_key)
  end

  def sample_games(sport_key)
    case sport_key
    when 'mlb'
      [
        build_sample_game('New York Yankees', 'Boston Red Sox', 'MLB', 'baseball', -150, 130, -1.5, 8.5),
        build_sample_game('Los Angeles Dodgers', 'San Francisco Giants', 'MLB', 'baseball', -180, 155, -1.5, 7.5),
        build_sample_game('Houston Astros', 'Texas Rangers', 'MLB', 'baseball', -120, 100, -1.5, 9.0),
        build_sample_game('Chicago Cubs', 'St. Louis Cardinals', 'MLB', 'baseball', 110, -130, 1.5, 8.0),
        build_sample_game('Atlanta Braves', 'Philadelphia Phillies', 'MLB', 'baseball', -140, 120, -1.5, 8.5),
      ]
    when 'nfl'
      [
        build_sample_game('Kansas City Chiefs', 'Buffalo Bills', 'NFL', 'football', -145, 125, -3.0, 48.5),
        build_sample_game('San Francisco 49ers', 'Dallas Cowboys', 'NFL', 'football', -160, 140, -3.5, 45.5),
        build_sample_game('Philadelphia Eagles', 'Miami Dolphins', 'NFL', 'football', -130, 110, -2.5, 51.0),
        build_sample_game('Baltimore Ravens', 'Cincinnati Bengals', 'NFL', 'football', -175, 150, -4.0, 47.0),
      ]
    when 'nba'
      [
        build_sample_game('Boston Celtics', 'Los Angeles Lakers', 'NBA', 'basketball', -200, 170, -5.5, 224.5),
        build_sample_game('Denver Nuggets', 'Golden State Warriors', 'NBA', 'basketball', -150, 130, -3.5, 228.0),
        build_sample_game('Milwaukee Bucks', 'Phoenix Suns', 'NBA', 'basketball', -135, 115, -2.5, 230.5),
      ]
    when 'nhl'
      [
        build_sample_game('Edmonton Oilers', 'Toronto Maple Leafs', 'NHL', 'hockey', -130, 110, -1.5, 6.5),
        build_sample_game('Colorado Avalanche', 'Vegas Golden Knights', 'NHL', 'hockey', 105, -125, 1.5, 6.0),
      ]
    else
      []
    end
  end

  def build_sample_game(home, away, league, sport, home_ml, away_ml, spread_pts, total_pts)
    spread_home_odds = spread_pts < 0 ? -110 : -110
    spread_away_odds = -110
    over_odds = -110
    under_odds = -110

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
        spread: { home: spread_home_odds, away: spread_away_odds, home_points: spread_pts, away_points: -spread_pts },
        total: { over: over_odds, under: under_odds, points: total_pts },
        sportsbook: 'DraftKings',
        raw_odds_count: 6
      }
    }
  end
end
