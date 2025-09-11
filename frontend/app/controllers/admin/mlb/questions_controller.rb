class Admin::Mlb::QuestionsController < Admin::QuestionsController

  def questions
    Question.mlb.includes(:topic)
  end

end
