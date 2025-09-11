describe 'api/games/index.json.v2.jbuilder', sport: 'Mlb' do
  include_context 'authenticated', :user
  before { assign(:games, games) }

  context 'with multiple games' do
    let(:games)     { Fabricate.times 5, :game, home_team: home_team }
    let(:home_team) { Fabricate :team, name: 'Home', primary_color: '#000000' }

    it 'renders game JSON' do
      render
      json[:games].size.should == 5
      json[:games].each do |_game|
        game = Game.find _game[:id]
        _game.should include :id, :start_time, :home_team, :away_team
        _game[:start_time].should == game.start_time.utc.iso8601
        _game[:home_team][:name].should == 'Home'
        _game[:home_team][:primary_color].should == '#000000'
      end
    end

    it 'busts the cache if the game changes' do
      -> { games.sample.update(start_time: 15.minutes.from_now) }.should bust_view_cache
    end

    it 'busts the cache if a team changes' do
      -> { home_team.update(primary_color: '#111111') }.should bust_view_cache
    end
  end
end