class Admin::Nfl::QuestionsController < Admin::QuestionsController

  def questions
    Question.nfl.includes(:topic)
  end

end
