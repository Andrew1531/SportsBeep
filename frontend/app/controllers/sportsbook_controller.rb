class SportsbookController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_and_account

  def index
    @sport = params[:sport] || 'mlb'
    @games = fetch_games_with_odds(@sport)
    @open_wagers = @user.wagers.open.recent.limit(5) rescue []
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
      :odds, :points, :amount_cents, :sportsbook,
      :is_parlay, :parlay_legs
    )
  end

  def fetch_games_with_odds(sport_key)
    service = OpticOddsService.new
    games = service.fixtures_with_odds(sport_key)
    return games if games.present?
    db_games(sport_key)
  rescue StandardError => e
    Rails.logger.error "Sportsbook fetch error: #{e.message}"
    db_games(sport_key)
  end

  def db_games(sport_key)
    model = case sport_key
            when 'mlb' then Mlb::Game
            when 'nfl' then Nfl::Game
            else nil
            end

    if model
      games = model.includes(:home_team, :away_team).order(start_time: :asc).limit(30).to_a
      if games.any?
        return games.map { |g| db_game_to_hash(g, sport_key) }
      end
    end

    generate_matchups(sport_key)
  rescue StandardError => e
    Rails.logger.error "DB games error: #{e.message}"
    generate_matchups(sport_key)
  end

  def db_game_to_hash(game, sport_key)
    home = "#{game.home_team.market} #{game.home_team.name}"
    away = "#{game.away_team.market} #{game.away_team.name}"
    league = sport_key.upcase
    is_live = game.status == 'IP'

    home_ml, away_ml = random_moneyline
    spread_pts = random_spread(sport_key)
    total_pts = random_total(sport_key)

    {
      fixture_id: "DB-#{game.id}",
      game_id: game.id.to_s,
      start_date: game.start_time&.iso8601 || (Time.now + rand(1..72).hours).iso8601,
      home_team: home,
      away_team: away,
      sport: sport_key,
      league: league,
      status: game.status || 'scheduled',
      is_live: is_live,
      odds: {
        moneyline: { home: home_ml, away: away_ml },
        spread: { home: -110, away: -110, home_points: spread_pts, away_points: -spread_pts },
        total: { over: -110, under: -110, points: total_pts },
        sportsbook: 'SportsBeep',
        raw_odds_count: 6
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
    when 'nba'
      [
        build_matchup('Boston Celtics', 'Los Angeles Lakers', 'NBA', 'nba', -200, 170, -5.5, 224.5),
        build_matchup('Denver Nuggets', 'Golden State Warriors', 'NBA', 'nba', -150, 130, -3.5, 228.0),
        build_matchup('Milwaukee Bucks', 'Phoenix Suns', 'NBA', 'nba', -135, 115, -2.5, 230.5),
      ]
    when 'nhl'
      [
        build_matchup('Edmonton Oilers', 'Toronto Maple Leafs', 'NHL', 'nhl', -130, 110, -1.5, 6.5),
        build_matchup('Colorado Avalanche', 'Vegas Golden Knights', 'NHL', 'nhl', 105, -125, 1.5, 6.0),
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
