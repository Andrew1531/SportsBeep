describe Api::Mlb::GamesController, version: 2 do
  include_context 'authenticated', :user

  describe 'GET index' do
    let(:home_team) { Fabricate :team }
    let(:away_team) { Fabricate :team }

    let!(:games) do
      [
        Fabricate(:game, start_time: 4.days.from_now, bettable: true, status: nil),
        Fabricate(:game, start_time: 6.days.from_now, bettable: true)
      ]
    end

    it 'returns a list of bettable games starting in the next 7 days (by default)' do
      get :index
      assigns(:games).should =~ games
    end

    it 'doesnt return games that started already' do
      Fabricate :game, start_time: 1.second.ago, bettable: true
      get :index
      assigns(:games).should =~ games
    end

    it 'returns a list of games starting in the next X days (if provided)' do
      get :index, days: 5
      assigns(:games).should =~ [games.first]
    end

    it 'returns a list of games in 0 days if the parameter is not an integer' do
      get :index, days: 'qwe'
      assigns(:games).size.should == 0
    end
  end

  describe 'GET show' do
    let(:game) { Fabricate :game }

    it 'assigns the game with the sent ID' do
      get :show, id: game
      assigns(:game).should == game
    end

    describe 'http caching', version: 2 do
      let!(:game) { Fabricate :game }
      # it 'busts cache on game update' do
      #   -> { game.touch }.should bust_cache(:show, id: game)
      # end
    end
  end
end