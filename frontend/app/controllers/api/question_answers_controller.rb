class Api::QuestionAnswersController < Api::BaseController

  before_action :set_ticket

  def index
    @answers = @ticket.answers
    respond_with @answers
  end

  def create
    authorize @ticket, :questions?
    @answers = QuestionAnswer.create! attributes
    @ticket.timer_states.destroy_all
    render json: {}, status: 201
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: 422
  end

  private

    def set_ticket
      @ticket = Ticket.find params[:ticket_id]
    end

    def attributes
      permitted_params[:answers].map do |answer|
        answer.merge ticket: @ticket, time: decrypt(answer[:time])
      end
    end

    def decrypt(time)
      @ticket.timer_states.where(encrypted_text: time).pluck(:value).first
    end

    def permitted_params
      params.permit answers: [:question_id, :answer_id, :time]
    end

end
