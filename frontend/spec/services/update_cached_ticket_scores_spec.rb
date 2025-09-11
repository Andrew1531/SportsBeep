describe UpdateCachedTicketScores do
  let!(:contest) { Fabricate :contest }
  let!(:tickets) { Fabricate.times 6, :ticket, contest: contest }

  it 'updates the contest ticket scores and placings' do
    tickets.each do |t|
      Fabricate :stat, player: t.players[0], game: contest.game, stat: Mlb::Stats::SINGLES, amount: 2
      t.cached_score.should == 0.0
      t.score!.should == 2.0
    end
    UpdateCachedTicketScores.new.perform(contest.game)
    tickets.each do |t|
      t.reload.cached_score.should == 2.0
      t.cached_placing.should be_in [1, 2, 3, 4, 5, 6]
    end
  end

end