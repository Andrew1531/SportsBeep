shared_examples_for 'games#index' do

  include_context 'authenticated', :user

  describe 'GET index' do
    let(:home_team) { Fabricate :team, market: 'HOME_MARKET', name: 'HOME_NAME', primary_color: '000000', secondary_color: '111111' }
    let(:away_team) { Fabricate :team, market: 'AWAY_MARKET', name: 'AWAY_NAME', primary_color: '222222', secondary_color: '333333' }

    before(:each) do
      Fabricate :game, start_time: 4.days.from_now, home_team: home_team, away_team: away_team, bettable: true
      Fabricate :game, start_time: 6.days.from_now, home_team: home_team, away_team: away_team, bettable: true
    end

    it 'returns a list of bettable games starting in the next 7 days (by default)' do
      get :index
      json[:games].size.should == 2
    end

    it 'doesnt return games that start within 5 minutes' do
      game = Fabricate :game, start_time: 4.minutes.from_now, home_team: home_team, away_team: away_team, bettable: true
      get :index
      assigns(:games).should_not include game
      json[:games].size.should == 2
    end

    it 'returns a list of games starting in the next X days (if provided)' do
      get :index, days: 5
      json[:games].size.should == 1
    end

    it 'returns a list of games in 0 days if the parameter is not an integer' do
      get :index, days: 'qwe'
      json[:games].size.should == 0
    end

    it 'returns each games start time and date' do
      get :index
      json[:games].each do |g|
        game = Game.find g[:id]
        g[:start_time].should == game.start_time.utc.iso8601
      end
    end

    it 'returns each games home and away team' do
      get :index
      json[:games].each do |g|
        g.should include :home_team, :away_team
      end
    end

    describe 'the team JSON' do
      before { get :index }

      it 'returns the team names' do
        json[:games].each do |g|
          g[:home_team][:name].should == 'HOME_NAME'
          g[:away_team][:name].should == 'AWAY_NAME'
        end
      end

      it 'returns the team markets' do
        json[:games].each do |g|
          g[:home_team][:market].should == 'HOME_MARKET'
          g[:away_team][:market].should == 'AWAY_MARKET'
        end
      end

      it 'returns the team colors' do
        json[:games].each do |g|
          g[:home_team][:primary_color].should   == '#000000'
          g[:home_team][:secondary_color].should == '#111111'
          g[:away_team][:primary_color].should   == '#222222'
          g[:away_team][:secondary_color].should == '#333333'
        end
      end
    end
  end

end