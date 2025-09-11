describe Contest do

  describe '#league_pick_games' do
    it 'returns the games that have been chosen for this contest' do
      game = Fabricate :game
      league_picks = Fabricate.times 3, :game, start_time: (game.start_time + 1.day)
      BettableGame.new(game).call!
      contest = Fabricate :contest, game: game
      ticket = Fabricate :ticket, contest: contest, league_pick_game: league_picks.last
      contest.league_pick_games.should == [league_picks.last]
      league_picks.last.reverse_league_pick_tickets.should == [ticket]
      league_picks.last.reverse_league_pick_contests.should == [contest]
    end
  end

  describe '#finalizable?' do
    let(:game) { Fabricate :game }
    let(:contest) { Fabricate :contest, game: game }
    let!(:league_picks) { Fabricate.times 3, :game, start_time: (game.start_time + 2.hours) }

    before do
      BettableGame.new(game).call!
      Fabricate :ticket, contest: contest, league_pick_game: league_picks.first
      Fabricate :ticket, contest: contest, league_pick_game: league_picks.second
    end

    it 'returns true if all chosen league pick games are ended' do
      game.update status: :ended
      contest.should_not be_finalizable
      league_picks.first.update(status: :ended)
      contest.reload.should_not be_finalizable
      league_picks.second.update(status: :ended)
      contest.reload.should be_finalizable
    end

    specify 'the contests game must be ended as well (in addition to the league picks' do
      league_picks.each { |lp| lp.update status: :ended }
      contest.reload.should_not be_finalizable
      game.update status: :ended
      contest.reload.should be_finalizable
    end
  end

  describe '.live' do
    it 'returns the contests where the games status is live' do
      Fabricate.times 2, :contest, game: Fabricate(:game, status: '')
      live = Fabricate :contest, game: Fabricate(:game, status: 'live')
      _sport(Contest).live.should == [live]
    end
  end

  describe '.upcoming' do
    it 'returns the contests where the game hasnt happened yet, but are bettable' do
      upcoming = Fabricate :contest, game: Fabricate(:game, bettable: true)
      Fabricate :contest, game: Fabricate(:game, bettable: false)
      Fabricate :contest, game: Fabricate(:game, bettable: true, status: :live)
      Fabricate :contest, game: Fabricate(:game, bettable: true, status: :finalized)
      Fabricate :contest, game: Fabricate(:game, bettable: true, status: :ended)
      _sport(Contest).upcoming.should == [upcoming]
    end
  end

  describe '.past, .finalized' do
    it 'returns the contests that are finalized' do
      past = Fabricate :contest, status: :finalized
      Fabricate :contest, game: Fabricate(:game, bettable: true)
      Fabricate :contest, game: Fabricate(:game, bettable: false)
      Fabricate :contest, game: Fabricate(:game, bettable: true, status: :live)
      Fabricate :contest, game: Fabricate(:game, bettable: true, status: :ended)
      _sport(Contest).past.should == [past]
      _sport(Contest).finalized.should == [past]
    end
  end

end
