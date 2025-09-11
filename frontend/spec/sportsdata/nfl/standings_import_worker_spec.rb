describe Nfl::StandingsImportWorker, sportsdata: true do

  let(:team) { Nfl::Team.find_by(name: 'Patriots') }

  before do
    Nfl::TeamImportWorker.new.perform
    Nfl::RosterImportWorker.new.perform
  end

  it 'pulls down the game statistics from SportsData' do
    subject.perform
    WebMock.should have_requested(:get, %r[sportsdatallc.org(.*)teams/(.*)/standings.json])
  end

  it 'updates existing stats instead of creating new ones' do
    subject.perform
    expect { subject.perform }.to_not change(TeamStat, :count)
  end

  it 'imports the teams wins, losses, and games played' do
    subject.perform
    team.stats[Nfl::Stats::GAMES].should == 16.0
    team.stats[Nfl::Stats::WINS].should == 12.0
    team.stats[Nfl::Stats::LOSSES].should == 4.0
  end

end