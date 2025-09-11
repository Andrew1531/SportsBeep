shared_examples_for 'tickets#show' do
  include_context 'authenticated', :user
  let(:ticket) { Fabricate :ticket }

  describe 'GET show' do
    context 'when the players dont have recorded stats yet' do
      it 'returns a blank array for the breakdown if they havent recorded any stats yet' do
        get :show, id: ticket
        response.status.should == 200
        json[:players].each do |player|
          player[:score].should == '0.0'
          player[:breakdown].should == []
        end
      end
    end

  end
end