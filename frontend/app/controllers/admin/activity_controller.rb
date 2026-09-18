class Admin::ActivityController < Admin::BaseController
  def index
    @report = AdminActivityReport.new(filter_params).call
  end

  def wager
    @wager = Wager.includes(:user, :approved_token).find(params[:id])
  end

  def entry
    @entry = Ticket.includes(
      :user, :approved_token, :players, :squads, :league_pick_game, :league_pick_team,
      answers: [:question, :answer],
      contest: { template: [:game, :pool] }
    ).find(params[:id])
  end

  private

  def filter_params
    params.permit(:token, :user_id, :search, :team, :game_id, :status, :sport, :page, :entry_page)
  end
end