class Admin::QuestionsController < Admin::BaseController

  before_action :set_question, only: [:edit, :update, :destroy]

  def index
    @questions = questions.sort do |a, b|
      [a.topic.stat.name, a.type] <=> [b.topic.stat.name, b.type]
    end
  end

  def new
    @question = Question.new
  end

  def create
    @question = Question.create permitted_params
    respond_with @question, location: collection_path
  end

  def edit
  end

  def update
    @question.update permitted_params
    respond_with @question, location: collection_path
  end

  def destroy
    @question.destroy
    respond_with @question, location: collection_path
  end

  private

    def set_question
      @question = Question.find params[:id]
    end

    def permitted_params
      params.require(:question).permit :topic_id, :text, :kind
    end

    def collection_path
      polymorphic_path [:admin, current_sport, Question]
    end

end