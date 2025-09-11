describe Api::Mlb::StatsController, version: 2 do
  include_context 'authenticated', :user

  let(:player) { Fabricate :player, position: '1B' }

  let(:statdata) do
    [
      Mlb::Stats::AT_BATS, Mlb::Stats::BATTING_AVERAGE, Mlb::Stats::HOME_RUNS, Mlb::Stats::RBIS, Mlb::Stats::WALKS, Mlb::Stats::SINGLES,
      Mlb::Stats::DOUBLES, Mlb::Stats::TRIPLES, Mlb::Stats::HIT_BY_PITCH, Mlb::Stats::STOLEN_BASES, Mlb::Stats::STRIKE_OUTS, Mlb::Stats::ON_BASE_PCT,
      Mlb::Stats::SLUGGING_PCT, Mlb::Stats::SAVES, Mlb::Stats::LOSSES, Mlb::Stats::ERA, Mlb::Stats::STARTS, Mlb::Stats::INNINGS_PITCHED,
      Mlb::Stats::HITS_ALLOWED, Mlb::Stats::RUNS_ALLOWED, Mlb::Stats::WHIP, Mlb::Stats::ON_BASE_AVERAGE, Mlb::Stats::WINS
    ]
  end

  let!(:season_stats) do
    statdata.map do |statdata|
      Fabricate :seasonal_stat, stat: statdata, player: player
    end
  end

  let!(:recent_stats) do
    statdata.map do |statdata|
      Fabricate :recent_stat, stat: statdata, player: player
    end
  end

  it 'busts cache if season stats change' do
    -> { season_stats.find { |s| s.stat == Mlb::Stats::SINGLES }.update(amount: 50) }.should bust_cache(:index, player_id: player)
  end

  it 'busts cache if recent stats change' do
    -> { recent_stats.find { |s| s.stat == Mlb::Stats::SINGLES }.update(amount: 50) }.should bust_cache(:index, player_id: player)
  end

  describe 'starting pitcher' do
    let(:player) { Fabricate :player, position: 'SP' }
    it 'retrieves only the season stats for a starting pitcher' do
      get :index, player_id: player
      assigns(:season_stats).map(&:abbr).should =~ %w(BB ERA HA HR IP K LOSS OBA RA STARTS WHIP WIN)
      assigns(:recent_stats).map(&:abbr).should =~ %w(BB ERA HA HR IP K LOSS OBA RA STARTS WHIP WIN)
    end
  end

  describe 'relief pitcher' do
    let(:player) { Fabricate :player, position: 'RP' }
    it 'retrieves only the season stats for a starting pitcher' do
      get :index, player_id: player
      assigns(:season_stats).map(&:abbr).should =~ %w(BB ERA HA HR IP K SAVE OBA RA STARTS WHIP WIN)
      assigns(:recent_stats).map(&:abbr).should =~ %w(BB ERA HA HR IP K SAVE OBA RA STARTS WHIP WIN)
    end
  end

  describe 'non-pitchers' do
    let(:player) { Fabricate :player, position: '1B' }
    it 'retrieves only the season stats for a starting pitcher' do
      get :index, player_id: player
      assigns(:season_stats).map(&:abbr).should =~ %w(AB AVG HR RBI BB S D T HBP SB K OBP SLG)
      assigns(:recent_stats).map(&:abbr).should =~ %w(AB AVG HR RBI BB S D T HBP SB K OBP SLG)
    end
  end
end

describe Api::Nfl::StatsController, version: 2, sport: 'Nfl' do
  include_context 'authenticated', :user

  describe 'running backs' do
    let(:player) { Fabricate :player, position: 'FB' }

    it 'displays 0s for stats that are missing' do
      Fabricate :seasonal_stat, stat: Nfl::Stats::RUSHING_YDS, player: player, amount: '1.23'
      get :index, player_id: player
      assigns(:season_stats).map(&:abbr).should =~ ['ATT', 'RUSH YD', 'RUSH TD', 'REC YD', 'REC TD', 'FUM']
      assigns(:recent_stats).map(&:abbr).should =~ ['ATT', 'RUSH YD', 'RUSH TD', 'REC YD', 'REC TD', 'FUM']
      json[:season_stats][0]['amount'].should == '0'
      json[:season_stats][1]['amount'].should == '1.23'
    end
  end
end


