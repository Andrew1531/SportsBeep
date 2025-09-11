describe 'api/stats/index.json.v2.jbuilder' do
  include_context 'authenticated', :user

  before do
    assign(:season_stats, season_stats)
    assign(:recent_stats, recent_stats)
  end

  let(:season_stats) { Fabricate.times 2, :seasonal_stat, stat: Mlb::Stats::SINGLES, amount: '10' }
  let(:recent_stats) { Fabricate.times 2, :recent_stat, stat: Mlb::Stats::SINGLES, amount: '10' }

  it 'includes the season stats JSON' do
    render
    json[:season_stats].each do |_json|
      _json[:name].should == 'Singles'
      _json[:abbr].should == 'S'
      _json[:amount].should == '10'
      _json[:points_per].should == '1'
      _json[:points].should == '10'
    end
  end

  it 'includes the recent stats JSON' do
    render
    json[:recent_stats].each do |_json|
      _json[:name].should == 'Singles'
      _json[:abbr].should == 'S'
      _json[:amount].should == '10'
      _json[:points_per].should == '1'
      _json[:points].should == '10'
    end
  end

  it 'busts whenever a season stat changes' do
    -> { season_stats.sample.update(amount: '11') }.should bust_view_cache
  end

  it 'busts whenever a recent stat changes' do
    -> { recent_stats.sample.update(amount: '11') }.should bust_view_cache
  end

end
