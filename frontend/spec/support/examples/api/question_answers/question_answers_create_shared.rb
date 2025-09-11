shared_examples_for 'question_answers#create' do
  include_context 'authenticated', :user

  describe 'POST create' do
    it 'sends question answers with encrypted timestamps' do
      ticket   = Fabricate :ticket, user: user
      time13_9 = ticket.timer_states.find_by(value: 13.9).encrypted_text
      answers  = ticket.questions.map do |q|
        { question_id: q.id, answer_id: ticket.game.home_team, time: time13_9 }
      end
      post :create, ticket_id: ticket, answers: answers
      response.status.should == 201
      ticket.answers.size.should == 6
      QuestionAnswer.last(6).each { |answer| answer.time.should == 13.9 }
      ticket.reload.timer_states.should be_empty
    end

    it 'responds with an error when the encrypted text param does not match a time' do
      ticket = Fabricate :ticket, user: user
      answers = ticket.questions.map do |q|
        { question_id: q.id, answer_id: ticket.game.home_team, time: 'garbage' }
      end
      post :create, ticket_id: ticket, answers: answers
      response.status.should == 422
      ticket.answers.size.should == 0
      json[:error].should match /Time can't be blank/
    end

    it 'responds with an error when the question has already been answered' do
      ticket = Fabricate :ticket, user: user
      time13_9 = ticket.timer_states.find_by(value: 13.9).encrypted_text
      answers = ticket.questions.map do |q|
        { question_id: q.id, answer_id: ticket.game.home_team, time: time13_9 }
      end
      answers << { question_id: ticket.questions.first.id, answer_id: ticket.game.home_team, time: time13_9 }
      ticket.answers.size.should == 0
      post :create, ticket_id: ticket, answers: answers
      response.status.should == 422
      json[:error].should match /Question has already been answered/
    end

    it 'responds with a 401 when the ticket isnt owned by the user' do
      ticket = Fabricate :ticket
      ticket.user.should_not == user
      post :create, ticket_id: ticket
      response.status.should == 401
    end
  end

end