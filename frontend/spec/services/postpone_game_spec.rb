describe PostponeGame do

  let(:game) { Fabricate :game, league_pick_count: 3 }

  before do
    BettableGame.new(game).call!
  end

  it 'destroys the games league picks' do
    game.league_picks.size.should == 3
    PostponeGame.new(game).call
    game.reload.league_picks.size.should == 0
    BettableGame.new(game).call
    game.reload.league_picks.size.should == 3
  end

end