Fabricator(:question_answer) do
  question { sequence(:q) { |i| Question.find_by(id: i) || Fabricate(:question) } }
  answer fabricator: :team
  ticket
  time { rand(1...140).fdiv 10 }

  after_create do |qa|
    UpdateCachedTicketScores.new.perform(qa.ticket.game)
  end

end