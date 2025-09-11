describe FinalizeContest do

  let(:game) { Fabricate :game }
  let(:contest) { Fabricate :contest, game: game }
  let!(:league_picks) { Fabricate.times 3, :game, start_time: (game.start_time + 2.hours) }

  before do
    BettableGame.new(game).call!
  end

  it 'sets the contest status to finalized' do
    FinalizeContest.new(contest).call
    contest.reload.status.should == 'finalized'
  end

  it 'determines ticket placement' do
    t1 = Fabricate :ticket, contest: contest, league_pick_game: league_picks.sample
    t2 = Fabricate :ticket, contest: contest, league_pick_game: league_picks.sample
    t3 = Fabricate :ticket, contest: contest, league_pick_game: league_picks.sample

    allow_any_instance_of(Contest).to receive(:tickets) { [t1, t2, t3] }
    expect(t1).to receive(:score) { 10 }
    expect(t2).to receive(:score) { 50 }
    expect(t3).to receive(:score) { 100 }

    FinalizeContest.new(contest).call
    t1.reload.placing.should == 3
    t2.reload.placing.should == 2
    t3.reload.placing.should == 1
    NotifyWinners.jobs.size.should == 1
  end

end