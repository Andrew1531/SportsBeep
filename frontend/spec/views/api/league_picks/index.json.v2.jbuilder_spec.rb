describe 'api/league_picks/index.json.v2.jbuilder', sport: 'Mlb' do
  include_context 'authenticated', :user
  let(:game) { Fabricate :game, league_pick_count: 3 }

  before do
    assign(:game, game)
    assign(:league_picks, game.league_picks)
  end

  it 'renders the games league picks' do
    render
    json[:games].size.should == 3
    json[:games].each do |_game|
      game = Game.find _game[:id]
      _game.should include :id, :start_time, :home_team, :away_team
      _game[:start_time].should == game.start_time.utc.iso8601
    end
  end
end

# MLB Specific:
describe 'api/league_picks/index.v2.jbuilder', sport: 'Mlb' do
  let(:game) { Fabricate :game, league_pick_count: 3 }

  before do
    game.teams.each do |team|
      team.stats.store Mlb::Stats::HOME_RUNS, 10
      team.stats.store Mlb::Stats::WINS, 20
      team.stats.store Mlb::Stats::LOSSES, 50
      team.stats.store Mlb::Stats::GAMES, 5
    end
  end

  it 'returns the league picks average home runs per game as the league pick stat' do
    render
    json[:games].each do |game|
      game[:home_team][:wins].should == '20'
      game[:home_team][:losses].should == '50'
      game[:home_team][:average_hr_per_game].should == '2'
      game[:away_team].should == game[:home_team]
    end
  end

end