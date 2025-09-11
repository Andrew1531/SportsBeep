describe 'api/teams/index.json.v2.jbuilder' do
  include_context 'authenticated', :user
  before { assign(:teams, teams) }

  let(:teams) { Fabricate.times 3, :team }

  it 'returns the teams/team partial JSON' do
    render
    json[:teams].each do |_json|
      _json.should include :id, :market, :name, :abbr, :wins, :losses, :league_pick_stat, :primary_color, :secondary_color
    end
  end

  it 'busts the cache whenever a team is updated' do
    -> { teams.sample.update(primary_color: '#111111') }.should bust_view_cache
  end

  it 'busts the cache whenever a team stat is updated' do
    -> { teams.sample.stats.store(Mlb::Stats::WINS, 99) }.should bust_view_cache
  end

  describe 'stat formatting' do
    let(:teams) { Fabricate.times 1, :team }

    it 'formats the wins and losses as integers' do
      teams.first.stats.store Mlb::Stats::WINS, 5.0
      teams.first.stats.store Mlb::Stats::LOSSES, 5.0
      render
      json[:teams][0][:wins].should == '5'
      json[:teams][0][:losses].should == '5'
    end

    describe 'league pick stat formatting' do
      it 'formats to 2 decimal' do
        teams.first.stats.store Mlb::Stats::GAMES, 4
        teams.first.stats.store Mlb::Stats::HOME_RUNS, 1
        render
        json[:teams][0][:league_pick_stat].should == '.25'
      end

      it 'formats to 3 decimal' do
        teams.first.stats.store Mlb::Stats::GAMES, 3
        teams.first.stats.store Mlb::Stats::HOME_RUNS, 1
        render
        json[:teams][0][:league_pick_stat].should == '.333'
      end

      it 'formats to 0 decimal' do
        teams.first.stats.store Mlb::Stats::GAMES, 100
        teams.first.stats.store Mlb::Stats::HOME_RUNS, 0
        render
        json[:teams][0][:league_pick_stat].should == '0'
      end
    end
  end
end