class Api::Nfl::SquadsController < Api::BaseController

  before_action :set_ticket

  def show
    @squad =
      case params[:id]
      when 'defense'
        Nfl::DefenseSquad
      when 'special_teams'
        Nfl::SpecialTeamsSquad
      when 'quarterbacks'
        Nfl::QuarterbackSquad
      end.new(@ticket)
    respond_with @squad
  end

  private

    def set_ticket
      @ticket = Ticket.find params[:ticket_id]
    end

end
