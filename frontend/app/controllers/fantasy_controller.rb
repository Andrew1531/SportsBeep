class FantasyController < ApplicationController
  before_action :authenticate_user!

  def index
    @sport = params[:sport] || 'mlb'
    @user = current_user
    @account = @user.account
    @has_beep = @account.balance_cents > 0

    if @sport == 'nfl'
      @games = safe_query { Nfl::Game.includes(:home_team, :away_team).where('start_time > ?', Time.now).order(start_time: :asc).limit(20).to_a } || []
      @contests = safe_query { Nfl::Contest.includes(template: [:game, :pool]).joins(:game).where('games.start_time > ?', Time.now).order('games.start_time ASC').limit(20).to_a } || []
      @my_tickets = safe_query { Nfl::Ticket.includes(contest: { template: [:game, :pool] }).where(user: @user).order(created_at: :desc).limit(20).to_a } || []
    else
      @games = safe_query { Mlb::Game.includes(:home_team, :away_team).where('start_time > ?', Time.now).order(start_time: :asc).limit(20).to_a } || []
      @contests = safe_query { Mlb::Contest.includes(template: [:game, :pool]).joins(:game).where('games.start_time > ?', Time.now).order('games.start_time ASC').limit(20).to_a } || []
      @my_tickets = safe_query { Mlb::Ticket.includes(contest: { template: [:game, :pool] }).where(user: @user).order(created_at: :desc).limit(20).to_a } || []
    end
  end

  def show
    @sport = params[:sport] || 'mlb'
    @user = current_user
    @account = @user.account

    if @sport == 'nfl'
      @game = safe_query { Nfl::Game.includes(:home_team, :away_team).find(params[:id]) }
      @players = safe_query { Nfl::Player.where(team: @game.teams).on_current_roster.order(:position, :last_name).to_a } || [] if @game
      @contests = safe_query { Nfl::Contest.includes(template: :pool).joins(:game).where(games: { id: @game.id }).to_a } || [] if @game
    else
      @game = safe_query { Mlb::Game.includes(:home_team, :away_team).find(params[:id]) }
      @players = safe_query { Mlb::Player.where(team: @game.teams).on_current_roster.order(:position, :last_name).to_a } || [] if @game
      @contests = safe_query { Mlb::Contest.includes(template: :pool).joins(:game).where(games: { id: @game.id }).to_a } || [] if @game
    end

    unless @game
      redirect_to fantasy_path(sport: @sport), alert: 'Game not found.'
      return
    end
  end

  def my_entries
    @user = current_user
    @account = @user.account
    @sport = params[:sport] || 'all'

    @mlb_tickets = safe_query { Mlb::Ticket.includes(contest: { template: [:game, :pool] }).where(user: @user).order(created_at: :desc).to_a } || []
    @nfl_tickets = safe_query { Nfl::Ticket.includes(contest: { template: [:game, :pool] }).where(user: @user).order(created_at: :desc).to_a } || []
    @all_entries = (@mlb_tickets + @nfl_tickets).sort_by { |t| t.created_at || Time.at(0) }.reverse
  end

  private

  def safe_query
    yield
  rescue => e
    Rails.logger.error "Fantasy query error: #{e.message}"
    nil
  end
end
