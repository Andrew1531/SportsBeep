shared_examples_for 'contests#show' do
  include_context 'authenticated', :user

  describe 'GET show' do
    let(:contest) { Fabricate :contest, user: user }

    it 'returns the contest ID' do
      get :show, id: contest
      json.should include :id
    end

    it 'returns all of the tickets in the contest in order of score' do
      tickets = Fabricate.times 3, :ticket, game: contest.game, pool: contest.template.pool
      get :show, id: contest
      json[:tickets].map { |t| t[:placing] }.should == [1, 2, 3, 4]
      json[:tickets].each do |ticket|
        ticket.should include :score, :user, :placing, :prize_pool
        ticket[:user].should include :username
      end
    end

    it 'returns the game JSON' do
      get :show, id: contest
      json.should include :game
    end
  end
end

shared_examples_for 'contests#show-v2' do
  context 'version 2', version: 2 do
    describe 'GET show' do
      let(:contest) { Fabricate :contest, user: user }
      let!(:tickets) do
        Fabricate.times 3, :ticket, game: contest.game, pool: contest.template.pool
      end

      it 'busts cache on contest update' do
        -> { contest.touch }.should bust_cache(:show, id: contest)
      end

      it 'returns the game ID' do
        get :show, id: contest
        json[:game].keys.should == ['id']
      end
    end
  end
end
