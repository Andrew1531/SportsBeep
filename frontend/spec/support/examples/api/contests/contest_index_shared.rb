shared_examples_for 'contests#index' do
  include_context 'authenticated', :user

  context 'v1' do
    let!(:live)     { Fabricate :contest, game: Fabricate(:game, status: :live), user: user  }
    let!(:upcoming) { Fabricate :contest, game: Fabricate(:game, bettable: true), user: user  }
    let!(:ended)    { Fabricate :contest, game: Fabricate(:game, status: :ended), user: user  }
    let!(:past)     { Fabricate :contest, status: :finalized, user: user  }
    let!(:other)    { Fabricate :contest, game: Fabricate(:game, bettable: false) }

    it 'returns live contests' do
      get :index, status: :live
      assigns(:contests).size.should == 2
      assigns(:contests).should include live
      assigns(:contests).should include ended
    end

    it 'returns upcoming contests' do
      get :index, status: :upcoming
      assigns(:contests).size.should == 2
      assigns(:contests).should include upcoming
      assigns(:contests).should include past
    end

    it 'returns past contests' do
      get :index, status: :past
      assigns(:contests).should == [past]
    end

    it 'returns all contests if no other status is given' do
      get :index, status: :asdf
      assigns(:contests).should include live, upcoming, past, ended
      json[:contests].size.should == 4
      json[:contests].each do |contest|
        contest.should include :id, :game
      end
    end

    it 'returns ticket information' do
      ticket = live.tickets.find_by(user: user)
      competitor = Fabricate :ticket, game: live.game, pool: live.pool
      Fabricate :stat, name: :hr, amount: 1, player: ticket.players.sample, game: live.game
      Fabricate :stat, name: :hr, amount: 2, player: competitor.players.sample, game: live.game
      get :index, status: :live
      json[:contests].find { |c| c[:id].to_i == live.id }[:tickets].first.tap do |ticket|
        ticket[:score].should == '4.0'
        ticket[:placing].should == 2
      end
    end
  end

  describe 'GET index sorting' do
    it 'sorts by start time and then home team name' do
      shared_time = 2.days.from_now
      c1 = Fabricate :contest, game: Fabricate(:game, start_time: 4.day.from_now, home_team: Fabricate(:team, name: 'A')), user: user
      c4 = Fabricate :contest, game: Fabricate(:game, start_time: shared_time, home_team: Fabricate(:team, name: 'D')), user: user
      c2 = Fabricate :contest, game: Fabricate(:game, start_time: 3.day.from_now, home_team: Fabricate(:team, name: 'B')), user: user
      c3 = Fabricate :contest, game: Fabricate(:game, start_time: shared_time, home_team: Fabricate(:team, name: 'C')), user: user
      get :index
      assigns(:contests).should == [c1, c2, c3, c4]
    end
  end

end

shared_examples_for 'contests#index-v2' do
  include_context 'authenticated', :user

  describe 'v2', version: 2 do
    let!(:contest) { Fabricate :contest }
    let!(:ticket) { Fabricate :ticket, game: contest.game, pool: contest.pool, user: user }

    it 'busts cache when contest or ticket is updated' do
      -> { contest.touch }.should bust_cache(:index)
    end

    it 'busts cache when the ticket is updated' do
      -> { ticket.touch }.should bust_cache(:index)
    end

    it 'returns ticket information' do
      Fabricate :stat, name: :hr, amount: 2, player: ticket.players.sample, game: ticket.game
      get :index
      json[:contests].first[:ticket].tap do |ticket|
        ticket.should include :id, :score, :prize_pool, :placing, :user
        ticket[:score].should == '8.0'
        ticket[:placing].should == 1
      end
    end
  end
end