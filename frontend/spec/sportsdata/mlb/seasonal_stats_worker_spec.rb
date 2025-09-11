describe Mlb::SeasonalStatsWorker, sportsdata: true, sport: 'Mlb' do

  let!(:game) { Fabricate :game }

  before do
    Mlb::TeamImportWorker.new.perform
    Mlb::RosterImportWorker.new.perform
  end

  it 'pulls down the game statistics from SportsData' do
    subject.perform
    WebMock.should have_requested(:get, %r[sportsdatallc.org/(.*)/seasontd/players/(.*).xml])
  end

  it 'updates existing stat lines instead of creating new ones' do
    subject.perform
    expect { subject.perform }.to_not change(SeasonalStat, :count)
  end

  describe 'a hitter' do
    let!(:player) { Mlb::Player.find_or_create_by(external_id: '000f4266-baa3-4065-b8c7-acd16e9dbe72') }

    it 'stores each stat correctly from the xml' do
      subject.perform
      player.seasonal_stats[Mlb::Stats::AT_BATS].should == 27
      player.seasonal_stats[Mlb::Stats::BATTING_AVERAGE].should == 0.185
      player.seasonal_stats[Mlb::Stats::RBIS].should == 5
      player.seasonal_stats[Mlb::Stats::WALKS].should == 2
      player.seasonal_stats[Mlb::Stats::SINGLES].should == 3
      player.seasonal_stats[Mlb::Stats::DOUBLES].should == 1
      player.seasonal_stats[Mlb::Stats::TRIPLES].should == 0
      player.seasonal_stats[Mlb::Stats::HOME_RUNS].should == 1
      player.seasonal_stats[Mlb::Stats::HIT_BY_PITCH].should == 0
      player.seasonal_stats[Mlb::Stats::STOLEN_BASES].should == 0
      player.seasonal_stats[Mlb::Stats::STRIKE_OUTS].should == 9
      player.seasonal_stats[Mlb::Stats::ON_BASE_PCT].should == 0.233
      player.seasonal_stats[Mlb::Stats::SLUGGING_PCT].should == 0.333
    end
  end

  describe 'a pitcher' do
    let(:player) { Mlb::Player.find_by(external_id: '002f8bc7-87df-4014-91b5-44db51523d5e') }

    it 'stores each stat correctly from the xml' do
      subject.perform
      player.seasonal_stats[Mlb::Stats::WINS].should == 0
      player.seasonal_stats[Mlb::Stats::LOSSES].should == 2
      player.seasonal_stats[Mlb::Stats::SAVES].should == 0
      player.seasonal_stats[Mlb::Stats::ERA].should == 6.353
      player.seasonal_stats[Mlb::Stats::STRIKE_OUTS].should == 11
      player.seasonal_stats[Mlb::Stats::WALKS].should == 3
      player.seasonal_stats[Mlb::Stats::STARTS].should == 0
      player.seasonal_stats[Mlb::Stats::INNINGS_PITCHED].should == 11.1
      player.seasonal_stats[Mlb::Stats::HITS_ALLOWED].should == 12
      player.seasonal_stats[Mlb::Stats::RUNS_ALLOWED].should == 8
      player.seasonal_stats[Mlb::Stats::HOME_RUNS].should == 3
      player.seasonal_stats[Mlb::Stats::WHIP].should == 1.324
      player.seasonal_stats[Mlb::Stats::ON_BASE_AVERAGE].should == 0.261
    end
  end

end