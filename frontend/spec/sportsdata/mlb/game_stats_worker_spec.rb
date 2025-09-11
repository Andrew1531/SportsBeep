describe Mlb::GameStatsWorker, sportsdata: true, sport: 'Mlb' do

  let!(:game) { Fabricate :game }

  before do
    Mlb::TeamImportWorker.new.perform
    Mlb::RosterImportWorker.new.perform
  end

  it 'pulls down the game statistics from SportsData' do
    subject.perform(game.id)
    WebMock.should have_requested(:get, %r[sportsdatallc.org/(.*)/statistics/(.*).xml])
  end

  it 'queues up the ticket cache update worker' do
    expect {
      subject.perform(game.id)
    }.to change { UpdateCachedTicketScores.jobs.size }.from(0).to(1)
  end

  it 'updates existing stat lines instead of creating new ones' do
    subject.perform(game.id)
    expect { subject.perform(game.id) }.to_not change(Mlb::Stat, :count)
  end

  describe 'a hitter' do
    let(:player) { Player.find_by(external_id: 'dba90413-2bf3-4767-9516-f3a6b7cfb53c') }

    it 'stores each stat correctly from the xml' do
      subject.perform(game.id)
      player.stats.where(game: game)[Mlb::Stats::SINGLES].should == 1
      player.stats.where(game: game)[Mlb::Stats::DOUBLES].should == 2
      player.stats.where(game: game)[Mlb::Stats::TRIPLES].should == 3
      player.stats.where(game: game)[Mlb::Stats::HOME_RUNS].should == 4
      player.stats.where(game: game)[Mlb::Stats::RUNS].should == 1
      player.stats.where(game: game)[Mlb::Stats::RBIS].should == 5
      player.stats.where(game: game)[Mlb::Stats::WALKS].should == 6
      player.stats.where(game: game)[Mlb::Stats::HIT_BY_PITCH].should == 0
      player.stats.where(game: game)[Mlb::Stats::OUTS].should == 10
    end
  end

  describe 'a pitcher' do
    let(:player) { Mlb::Player.find_by(external_id: '0d674411-7f4d-4bc0-ba7a-853458580bab') }

    it 'stores each stat correctly from the xml' do
      subject.perform(game.id)
      player.stats.each { |stat| stat.team.should == Mlb::Team.find_by(name: 'Nationals') }
      player.stats.where(game: game)[Mlb::Stats::WINS].should == 0
      player.stats.where(game: game)[Mlb::Stats::LOSSES].should == 1
      player.stats.where(game: game)[Mlb::Stats::STARTS].should == 1
      player.stats.where(game: game)[Mlb::Stats::ERA].should == 1.227
      player.stats.where(game: game)[Mlb::Stats::INNINGS_PITCHED].should == 7.1
      player.stats.where(game: game)[Mlb::Stats::STRIKE_OUTS].should == 7
      player.stats.where(game: game)[Mlb::Stats::RUNS_ALLOWED].should == 1
      player.stats.where(game: game)[Mlb::Stats::HITS_ALLOWED].should == 4
      player.stats.where(game: game)[Mlb::Stats::HOME_RUNS_ALLOWED].should == 0
      player.stats.where(game: game)[Mlb::Stats::WALKS].should == 2
      player.stats.where(game: game)[Mlb::Stats::HIT_BATTER].should == 0
      player.stats.where(game: game)[Mlb::Stats::ON_BASE_AVERAGE].should == 0.174
      player.stats.where(game: game)[Mlb::Stats::WHIP].should == 0.818
    end
  end

  it 'stores fielding errors' do
    player = Player.find_by(external_id: '16c0d07f-94f0-4fec-8cfa-4703ec344865')
    subject.perform(game.id)
    player.stats.where(game: game)[Mlb::Stats::ERRORS].should == 1
  end

  it 'knows when a game is over' do
    worker = subject
    worker.perform(game.id)
    worker.send(:ended?).should be_false
    # should requeue:
    worker.class.jobs.size.should == 1
  end

  it 'knows when a game is postponed and stops polling' do
    worker = subject
    expect(worker).to receive(:postponed?) { true }
    worker.perform(game.id)
    game.reload.status?(:postponed).should == true
    worker.class.jobs.size.should == 0
  end

end