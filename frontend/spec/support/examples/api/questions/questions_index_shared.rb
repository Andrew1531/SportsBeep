shared_examples_for 'questions#index' do
  include_context 'authenticated', :user

  describe 'GET index' do
    it 'returns the tickets questions' do
      ticket = Fabricate :ticket, user: user
      get :index, ticket_id: ticket
      response.status.should == 200
      json[:questions].size.should == 6
      json[:questions].each do |question|
        question.should include :id, :type, :text
        question[:type].should match /(best|bust)/
      end
    end

    it 'returns a 401 when trying to fetch a ticket that isnt yours' do
      ticket = Fabricate :ticket
      ticket.user.should_not == user
      get :index, ticket_id: ticket
      response.status.should == 401
    end
  end

end