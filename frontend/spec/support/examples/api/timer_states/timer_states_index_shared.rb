shared_examples_for 'timer_states#index' do
  include_context 'authenticated', :user

  describe 'GET index' do
    let!(:ticket) { Fabricate :ticket }

    it 'returns all ticket states for a ticket' do
      get :index, ticket_id: ticket
      response.status.should == 200
      json[:timer_states].size.should == 141
      json[:timer_states].each do |team|
        team.should include :id, :encrypted_text
      end
    end
  end

end