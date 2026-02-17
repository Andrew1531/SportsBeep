class GamesController < ApplicationController
  before_action :authenticate_user!

  def index
    @sport = params[:sport] || 'mlb'
    @user = current_user
    @account = @user.account
    @has_beep = @account.balance_cents > 0

    if @sport == 'nfl'
      @teams = safe_query { Nfl::Team.order(:name).to_a } || []
      @games = safe_query { Nfl::Game.includes(:home_team, :away_team).order(start_time: :asc).limit(20).to_a } || []
      @contests = safe_query { Nfl::Contest.where(status: 'open').order(created_at: :desc).limit(10).to_a } || []
    else
      @teams = safe_query { Mlb::Team.order(:name).to_a } || []
      @games = safe_query { Mlb::Game.includes(:home_team, :away_team).order(start_time: :asc).limit(20).to_a } || []
      @contests = safe_query { Mlb::Contest.where(status: 'open').order(created_at: :desc).limit(10).to_a } || []
    end
  end

  private

  def safe_query
    yield
  rescue => e
    Rails.logger.error "Games query error: #{e.message}"
    nil
  end
end
