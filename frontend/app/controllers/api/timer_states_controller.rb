class Api::TimerStatesController < Api::BaseController

  def index
    ticket = Ticket.find params[:ticket_id]
    @timer_states = ticket.timer_states
    respond_with @timer_states
  end

end
