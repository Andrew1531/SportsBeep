describe Mlb::StandingsImportWorker, sportsdata: true do

  let(:team) { Mlb::Team.find_by(name: 'Cardinals') }

  before do
    Mlb::TeamImportWorker.new.perform
    Mlb::RosterImportWorker.new.perform
  end

  it 'pulls down the game statistics from SportsData' do
    subject.perform
    WebMock.should have_requested(:get, %r[sportsdatallc.org/(.*)/standings/(.*).xml])
  end

  it 'updates existing stats instead of creating new ones' do
    subject.perform
    expect { subject.perform }.to_not change(TeamStat, :count)
  end

  it 'imports the teams games played' do
    subject.perform
    team.stats[Mlb::Stats::GAMES].should == 41.0
  end

end