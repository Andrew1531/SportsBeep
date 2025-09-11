shared_examples_for 'scoresheets#show' do
  include_context 'authenticated', :user

  let(:ticket) { Fabricate :ticket }
  let(:player) { Fabricate :player }

  context 'when the players dont have recorded stats yet' do
    it 'returns a blank array for the breakdown if they havent recorded any stats yet' do
      get :show, ticket_id: ticket, player_id: player
      response.status.should == 200
      json[:score].should == '0.0'
      json[:stats].should == []
    end
  end

end
