describe Api::Mlb::TimerStatesController, version: 2 do
  include_context 'authenticated', :user

  describe 'GET index' do
    let(:ticket) { Fabricate :ticket }

    it 'returns all ticket states for a ticket' do
      get :index, ticket_id: ticket
      response.status.should == 200
      assigns(:timer_states).size.should == 141
    end
  end

end