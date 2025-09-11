class Api::ContestsController < Api::BaseController
  etag { current_user.id }

  def index
    @contests = sort(contests.send(scope).includes(:pool, :tickets, game: { home_team: :stats, away_team: :stats }))
    @contests = paginate(@contests)
    @tickets = current_user.tickets.where(contest_id: @contests.map(&:id)).includes(:league_pick_game, :league_pick_team, :user, :answers)
    respond_with @contests
  end

  def show
    @contest = Contest.find params[:id]
    authorize @contest
    @tickets = @contest.tickets.sort_by(&:score).reverse
    respond_with @contest
  end

  private

    def scope
      case params[:status]
      when 'live', 'upcoming', 'past'
        params[:status]
      else
        :all
      end
    end

    def sort(contests)
      contests.joins(game: [:home_team]).order('games.start_time DESC, teams.name')
    end

end
