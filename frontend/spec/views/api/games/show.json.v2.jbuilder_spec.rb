describe 'api/games/show.json.v2.jbuilder', sport: 'Mlb' do
  include_context 'authenticated', :user
  before { assign(:game, game) }

  let(:game)      { Fabricate :game, home_team: home_team }
  let(:home_team) { Fabricate :team, name: 'Home', primary_color: '#000000' }

  it 'renders game JSON' do
    render
    json.should include :id, :start_time, :home_team, :away_team
    json[:start_time].should == game.start_time.utc.iso8601
    json[:home_team][:name].should == 'Home'
    json[:home_team][:primary_color].should == '#000000'
  end

  it 'busts the cache if the game changes' do
    -> { game.update(start_time: 15.minutes.from_now) }.should bust_view_cache
  end

  it 'busts the cache if the home or away team changes' do
    -> { game.home_team.update(primary_color: '111111') }.should bust_view_cache
    -> { game.away_team.update(primary_color: '111111') }.should bust_view_cache
  end

end