class Admin::DashboardController < Admin::BaseController

  def index
    @stats = {
      users: User.count,
      active_contests: defined?(Contest) && Contest.respond_to?(:active) ? Contest.active.count : 0,
      mlb_games: Mlb::Game.count,
      nfl_games: defined?(Nfl::Game) ? Nfl::Game.count : 0,
      promo_codes: PromoCode.count,
      administrators: Administrator.count
    }
    
    @recent_users = User.order(created_at: :desc).limit(10)
    @recent_contests = defined?(Contest) ? Contest.order(created_at: :desc).limit(5) : []
  end

end
