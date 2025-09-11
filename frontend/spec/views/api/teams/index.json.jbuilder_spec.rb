describe 'api/teams/index.json.jbuilder' do
  include_context 'authenticated', :user
  before { assign(:teams, teams) }

  let(:teams) { Fabricate.times 3, :team }

  it 'returns the teams/team partial JSON' do
    render
    json[:teams].each do |_json|
      _json.should include :id, :market, :name, :abbr, :wins, :losses, :average_hr_per_game, :primary_color, :secondary_color
    end
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

    describe 'average hr per game formatting' do
      it 'formats to 2 decimal' do
        teams.first.stats.store Mlb::Stats::GAMES, 4
        teams.first.stats.store Mlb::Stats::HOME_RUNS, 1
        render
        json[:teams][0][:average_hr_per_game].should == '.25'
      end

      it 'formats to 3 decimal' do
        teams.first.stats.store Mlb::Stats::GAMES, 3
        teams.first.stats.store Mlb::Stats::HOME_RUNS, 1
        render
        json[:teams][0][:average_hr_per_game].should == '.333'
      end

      it 'formats to 0 decimal' do
        teams.first.stats.store Mlb::Stats::GAMES, 100
        teams.first.stats.store Mlb::Stats::HOME_RUNS, 0
        render
        json[:teams][0][:average_hr_per_game].should == '0'
      end
    end
  end
end