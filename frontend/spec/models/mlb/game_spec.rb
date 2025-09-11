describe Mlb::Game, sport: 'Mlb' do

  let!(:pool) { Fabricate :pool, default: true }

  describe 'enqueing the game import worker', sportsdata: true do
    let(:game) { Fabricate :game }

    it 'queues up the worker when activated' do
      game.activated = true
      game.save
      expect(Mlb::GameStatsWorker).to have_enqueued_job(game.id)
    end

    it 'requeues itself after importing the data until the game has closed' do
      expect_any_instance_of(Mlb::GameStatsWorker).to receive(:ended?) { true }
      game.activated = true
      game.save
      expect(Mlb::GameStatsWorker).to have_enqueued_job(game.id)
      Mlb::GameStatsWorker.drain
      expect(Mlb::GameStatsWorker).to_not have_enqueued_job(game.id)
    end

    it 'queues up the lineup worker when activated' do
      game.activated = true
      game.save
      expect(Mlb::LineupWorker).to have_enqueued_job(game.id)
    end

    it 'requeues the lineup worker until the game has started' do
      expect_any_instance_of(Mlb::Game).to receive(:future?) { false }
      game.activated = true
      game.save
      expect(Mlb::LineupWorker).to have_enqueued_job(game.id)
      Mlb::LineupWorker.drain
      expect(Mlb::LineupWorker).to_not have_enqueued_job(game.id)
    end
  end

  describe 'reverse league picks' do
    let(:game) { Fabricate :game }
    let(:league_pick) { Fabricate :game }

    it 'returns games that include the game as a league pick' do
      game.league_picks << league_pick
      game.league_picks.should == [league_pick]
      league_pick.reverse_league_picks.should == [game]
      league_pick.league_picks.should be_empty
    end
  end

  describe 'status?' do
    it 'returns true with either a symbol or string parameter' do
      game = Fabricate :game, status: :live
      game.status?(:live).should  == true
      game.status?('live').should == true
      game.status?(:ended).should == false
    end
  end

end
