class Admin::DashboardController < Admin::BaseController

  def index
    @stats = {
      users: User.count,
      active_contests: safe_count { Contest.active },
      mlb_games: safe_count { Mlb::Game },
      nfl_games: safe_count { Nfl::Game },
      promo_codes: PromoCode.count,
      administrators: Administrator.count
    }
    
    @recent_users = User.order(created_at: :desc).limit(10)
    @recent_contests = safe_collection { Contest.order(created_at: :desc).limit(5) }
  end

  private

  def safe_count
    yield.count
  rescue NameError, NoMethodError
    0
  end

  def safe_collection
    yield
  rescue NameError, NoMethodError
    []
  end

end
