describe EndGame do

  let(:game) { Fabricate :game }

  describe 'contest finalization' do
    let!(:contest) { Fabricate :contest, game: game }
    let!(:league_picks) { Fabricate.times 3, :game, start_time: (game.start_time + 2.hours) }

    before do
      BettableGame.new(game).call!
    end

    it 'finalizes the contest when all chosen league picks are finalized' do
      EndGame.new(game).call
      t1 = Fabricate :ticket, contest: contest, league_pick_game: league_picks.first
      t3 = Fabricate :ticket, contest: contest, league_pick_game: league_picks.third
      EndGame.new(league_picks.first).call
      contest.reload.should_not be_finalizable
      EndGame.new(league_picks.second).call
      contest.reload.should_not be_finalizable
      EndGame.new(league_picks.third).call
      contest.reload.should be_finalizable
    end

    it 'finalizes the contest when the game ends if the league picks ended before it' do
      league_picks.each { |lp| EndGame.new(lp).call }
      EndGame.new(game).call
      contest.reload.status.should == 'finalized'
    end

    describe '#contests_that_are_waiting_on' do
      let(:league_pick) { contest.league_picks.sample }
      let(:game2) { Fabricate :game, start_time: 500.days.from_now }
      let!(:contest2) { Fabricate :contest, game: game2 }
      let!(:league_picks2) { Fabricate.times 3, :game, start_time: (game2.start_time + 2.hours) }

      before do
        BettableGame.new(game2).call!
        Fabricate :ticket, contest: contest, league_pick_game: league_pick
      end

      it 'only returns contests that have the contest as a league pick' do
        contest.league_picks.should_not == contest2.league_picks
        EndGame.new(league_pick).send(:contests_that_are_waiting_on, league_pick).should == [contest]
      end

      it 'does not return contests that are finalized already' do
        contest.update(status: :finalized)
        EndGame.new(league_pick).send(:contests_that_are_waiting_on, league_pick).should == []
      end
    end

  end
end