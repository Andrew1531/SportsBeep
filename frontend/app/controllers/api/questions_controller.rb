class Api::QuestionsController < Api::BaseController

  def index
    ticket = Ticket.find params[:ticket_id]
    authorize ticket, :questions?
    @questions = ticket.questions
    respond_with @questions
  end

end
