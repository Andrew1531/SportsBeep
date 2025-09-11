Fabricator(:contest_template) do
  game
  pool

  before_validation do |template|
    template.best_questions = BestQuestion.all.sample(3)
    template.bust_questions = BustQuestion.all.sample(3)
  end

end