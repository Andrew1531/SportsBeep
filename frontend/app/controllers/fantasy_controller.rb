class FantasyController < ApplicationController
  before_action :authenticate_user!

  def index
    @sport = params[:sport] || 'mlb'
    @user = current_user
    @account = @user.account
    @has_beep = @account.balance_cents > 0

    if @sport == 'nfl'
      @games    = safe_query { Nfl::Game.includes(:home_team, :away_team).where('start_time > ?', Time.now).order(start_time: :asc).limit(20).to_a } || []
      @contests = safe_query { Nfl::Contest.includes(template: [:game, :pool]).joins(:game).where('games.start_time > ?', Time.now).order('games.start_time ASC').limit(20).to_a } || []
      @my_tickets = safe_query { Nfl::Ticket.includes(contest: { template: [:game, :pool] }).where(user: @user).order(created_at: :desc).limit(20).to_a } || []
    else
      @games    = safe_query { Mlb::Game.includes(:home_team, :away_team).where('start_time > ?', Time.now).order(start_time: :asc).limit(20).to_a } || []
      @contests = safe_query { Mlb::Contest.includes(template: [:game, :pool]).joins(:game).where('games.start_time > ?', Time.now).order('games.start_time ASC').limit(20).to_a } || []
      @my_tickets = safe_query { Mlb::Ticket.includes(contest: { template: [:game, :pool] }).where(user: @user).order(created_at: :desc).limit(20).to_a } || []
    end
  end

  def show
    @sport = params[:sport] || 'mlb'
    @user  = current_user
    @account = @user.account

    if @sport == 'nfl'
      @game     = safe_query { Nfl::Game.includes(:home_team, :away_team).find(params[:id]) }
      @players  = safe_query { Nfl::Player.where(team: @game.teams).on_current_roster.order(:position, :last_name).to_a } || [] if @game
      @contests = safe_query { Nfl::Contest.includes(template: :pool).joins(:game).where(games: { id: @game.id }).to_a } || [] if @game
    else
      @game     = safe_query { Mlb::Game.includes(:home_team, :away_team).find(params[:id]) }
      @players  = safe_query { Mlb::Player.where(team: @game.teams).on_current_roster.order(:position, :last_name).to_a } || [] if @game
      @contests = safe_query { Mlb::Contest.includes(template: :pool).joins(:game).where(games: { id: @game.id }).to_a } || [] if @game
    end

    unless @game
      redirect_to fantasy_path(sport: @sport), alert: 'Game not found.'
      return
    end
  end

  def enter_contest
    @contest = Mlb::Contest.includes(template: [:game, :pool]).find(params[:contest_id])
    @user    = current_user
    @account = @user.account

    best_ids = Array(params[:best_player_ids]).map(&:to_i).uniq.first(3)
    bust_ids = Array(params[:bust_player_ids]).map(&:to_i).uniq.first(3)

    if best_ids.length != 3 || bust_ids.length != 3
      redirect_to fantasy_game_path(@contest.template.game.id, sport: 'mlb'),
                  alert: 'You must pick exactly 3 BEST and 3 BUST players.'
      return
    end

    if (best_ids & bust_ids).any?
      redirect_to fantasy_game_path(@contest.template.game.id, sport: 'mlb'),
                  alert: 'A player cannot be both a BEST and a BUST pick.'
      return
    end

    pool      = @contest.template.pool
    entry_fee = pool&.entry_fee.to_f
    balance   = @account.balance_cents.to_f / 100.0

    if entry_fee > 0 && balance < entry_fee
      redirect_to fantasy_game_path(@contest.template.game.id, sport: 'mlb'),
                  alert: "Insufficient balance. Entry fee is #{entry_fee.round(2)} $BEEP."
      return
    end

    all_player_ids = best_ids + bust_ids
    players = Mlb::Player.where(id: all_player_ids)

    ActiveRecord::Base.transaction do
      ticket = Mlb::Ticket.new(contest: @contest, user: @user)
      ticket.save(validate: false)

      best_ids.each do |pid|
        TicketPlayer.create!(ticket: ticket, player_id: pid, position: 'best')
      end
      bust_ids.each do |pid|
        TicketPlayer.create!(ticket: ticket, player_id: pid, position: 'bust')
      end

      if entry_fee > 0
        fee_cents = (entry_fee * 100).round
        @account.update_columns(balance_cents: @account.balance_cents - fee_cents)
      end

      @ticket = ticket
    end

    redirect_to my_entries_path, notice: 'Contest entered! Good luck with your Best/Bust picks!'
  rescue => e
    Rails.logger.error "enter_contest error: #{e.message}\n#{e.backtrace.first(5).join("\n")}"
    redirect_to fantasy_path(sport: 'mlb'), alert: 'Unable to enter contest. Please try again.'
  end

  def my_entries
    @user    = current_user
    @account = @user.account
    @sport   = params[:sport] || 'all'

    @mlb_tickets = safe_query { Mlb::Ticket.includes(contest: { template: [:game, :pool] }, ticket_players: :player).where(user: @user).order(created_at: :desc).to_a } || []
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
