describe Api::Mlb::QuestionsController, version: 2 do
  include_context 'authenticated', :user

  describe 'GET index' do
    it 'returns the tickets questions' do
      ticket = Fabricate :ticket, user: user
      get :index, ticket_id: ticket
      assigns(:questions).should =~ ticket.questions
    end

    it 'returns a 401 when trying to fetch a ticket that isnt yours' do
      ticket = Fabricate :ticket
      get :index, ticket_id: ticket
      response.status.should == 401
    end
  end

end