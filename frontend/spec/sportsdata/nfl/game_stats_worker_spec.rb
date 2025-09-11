describe Nfl::GameStatsWorker, sportsdata: true, sport: 'Nfl' do

  let!(:game) { Fabricate :game }

  before do
    Nfl::TeamImportWorker.new.perform
    Nfl::RosterImportWorker.new.perform
  end

  it 'pulls down the game statistics from SportsData' do
    subject.perform(game.id)
    WebMock.should have_requested(:get, %r[sportsdatallc.org/(.*)/statistics.json])
  end

  it 'queues up the ticket cache update worker' do
    expect {
      subject.perform(game.id)
    }.to change { UpdateCachedTicketScores.jobs.size }.from(0).to(1)
  end

  it 'updates existing stat lines instead of creating new ones' do
    subject.perform(game.id)
    expect { subject.perform(game.id) }.to_not change(Nfl::Stat, :count)
  end

  describe 'a wide receiver' do
    let(:player) { Player.find_by(external_id: '16e33176-b73e-49b7-b0aa-c405b47a706e') }

    it 'stores each stat correctly from the xml' do
      subject.perform(game.id)
      player.stats.where(game: game)[Nfl::Stats::RUSHING_ATTEMPTS].should == 1
      player.stats.where(game: game)[Nfl::Stats::RUSHING_TDS].should == 100
      player.stats.where(game: game)[Nfl::Stats::RECEPTIONS].should == 5
      player.stats.where(game: game)[Nfl::Stats::RECEIVING_YDS].should == 71
      player.stats.where(game: game)[Nfl::Stats::RECEIVING_TDS].should == 5
      player.stats.where(game: game)[Nfl::Stats::FUMBLES].should == 1
      player.stats.where(game: game)[Nfl::Stats::FUMBLES_LOST].should == 2
      player.stats.where(game: game)[Nfl::Stats::PUNT_RETURN_TDS].should == 4
      player.stats.where(game: game)[Nfl::Stats::KICK_RETURN_TDS].should == 5
    end
  end

  describe 'team game stats' do
    it 'stores team game stats (for best/bust question scoring)' do
      subject.perform(game.id)
      stats = game.team_stats.where(team: Team.find_by(abbr: 'PIT'))
      stats[Nfl::Stats::TURNOVERS].should == 2
      stats[Nfl::Stats::PENALTIES].should == 4
      stats[Nfl::Stats::PENALTY_YDS].should == 47
      stats[Nfl::Stats::RED_ZONE_PCT].should == 50
      stats[Nfl::Stats::THIRD_DOWN_CV].should == 4
      stats[Nfl::Stats::FOURTH_DOWN_CV].should == 1
      stats[Nfl::Stats::TOTAL_YDS].should == 222
      stats[Nfl::Stats::FIRST_DOWNS].should == 14
      stats[Nfl::Stats::CHALLENGES].should == 0
    end
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