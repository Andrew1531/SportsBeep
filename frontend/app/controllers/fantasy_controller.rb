class FantasyController < ApplicationController
  before_action :authenticate_user!

  def index
    if params[:sport].to_s.downcase == 'nfl'
      redirect_to nfl_fantasy_path
      return
    end

    @sport = params[:sport] || 'mlb'
    @user = current_user
    @account = @user.account
    @has_beep = @account.balance_cents > 0
    @approved_tokens = ApprovedToken.enabled.order(:ticker)

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
    if params[:sport].to_s.downcase == 'nfl'
      redirect_to nfl_fantasy_game_path(params[:id])
      return
    end

    @sport = params[:sport] || 'mlb'
    @user  = current_user
    @account = @user.account
    @approved_tokens = ApprovedToken.enabled.order(:ticker)

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
    if params[:sport].to_s.downcase == 'nfl' ||
        Contest.where(id: params[:contest_id], type: 'Nfl::Contest').exists?
      contest = Nfl::Contest.find_by(id: params[:contest_id])
      destination = contest ? nfl_fantasy_game_path(contest.game) : nfl_fantasy_path
      redirect_to destination, alert: 'Use the NFL entry form to choose the complete original roster.'
      return
    end

    @contest = Mlb::Contest.includes(template: [:game, :pool]).find(params[:contest_id])
    @user    = current_user
    @account = @user.account
    token = ApprovedToken.enabled.find_by(id: params[:approved_token_id])
    unless token
      redirect_to fantasy_path(sport: 'mlb'), alert: 'Choose an approved token to enter this contest.'
      return
    end

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
    entry_fee = pool&.entry_fee
    fee_units = token.parse_amount!(entry_fee.to_s)
    balance = @account.token_balance_for(token).balance_units.to_i

    if fee_units.positive? && balance < fee_units
      redirect_to fantasy_game_path(@contest.template.game.id, sport: 'mlb'),
                  alert: "Insufficient balance. Entry fee is #{entry_fee.round(2)} $BEEP."
      return
    end

    all_player_ids = best_ids + bust_ids
    players = Mlb::Player.where(id: all_player_ids)

    ActiveRecord::Base.transaction do
      ticket = Mlb::Ticket.new(contest: @contest, user: @user, approved_token: token, entry_fee_units: fee_units)
      ticket.save(validate: false)

      best_ids.each do |pid|
        TicketPlayer.create!(ticket: ticket, player_id: pid, position: 'best')
      end
      bust_ids.each do |pid|
        TicketPlayer.create!(ticket: ticket, player_id: pid, position: 'bust')
      end

      if fee_units.positive?
        pool_name = (@contest.template.pool.name rescue nil) || 'Fantasy contest'
        # Lock + re-check inside the lock, debit, and record a ledger entry so
        # every balance change has an auditable Transaction (no silent moves).
        @account.with_lock do
          token_balance = @account.token_balance_for(token)
          raise "Insufficient #{token.ticker} balance" if token_balance.balance_units.to_i < fee_units
          token_balance.update!(balance_units: token_balance.balance_units.to_i - fee_units)
          ContestEntryFeeTransaction.create!(
            account:      @account,
            approved_token: token,
            amount_units: -fee_units,
            amount_cents: 0,
            description:  "Contest entry fee — #{pool_name}",
            status:       'completed'
          )
        end
      end

      @ticket = ticket
    end

    redirect_to my_entries_path, notice: 'Contest entered! Good luck with your Best/Bust picks!'
  rescue TokenAmount::InvalidAmount => e
    redirect_to fantasy_path(sport: 'mlb'), alert: e.message
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
