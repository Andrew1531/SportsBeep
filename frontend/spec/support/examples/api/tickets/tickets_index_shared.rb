shared_examples_for 'tickets#index' do
  include_context 'authenticated', :user

  let(:contest) { Fabricate :contest }

  describe 'GET index' do
    it 'returns a list of all the tickets in the contest' do
      Fabricate :ticket
      tickets = Fabricate.times 6, :ticket, contest: contest
      get :index, contest_id: contest
      json[:tickets].size.should == 6
      json[:tickets].map { |_json| _json[:id] }.sort.should == tickets.map(&:id).sort
    end
  end

end

