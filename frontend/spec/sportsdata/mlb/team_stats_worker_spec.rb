describe Mlb::TeamStatsWorker, sportsdata: true do

  let(:team) { Mlb::Team.find_by(name: 'Cardinals') }

  before do
    Mlb::TeamImportWorker.new.perform
    Mlb::RosterImportWorker.new.perform
  end

  it 'pulls down the game statistics from SportsData' do
    subject.perform
    WebMock.should have_requested(:get, %r[sportsdatallc.org/(.*)/seasontd/teams/(.*).xml])
  end

  it 'updates existing stats instead of creating new ones' do
    subject.perform
    expect { subject.perform }.to_not change(TeamStat, :count)
  end

  it 'imports the teams home runs, wins, and losses' do
    subject.perform
    team.stats.find_by(stat: Mlb::Stats::HOME_RUNS.id).amount.should == 23
    team.stats.find_by(stat: Mlb::Stats::WINS.id).amount.should == 21
    team.stats.find_by(stat: Mlb::Stats::LOSSES.id).amount.should == 20
  end

end