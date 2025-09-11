describe BettableGame do

  let(:game) { Fabricate :game, pools: [] }

  describe 'determine league picks' do
    let!(:league_picks) { Fabricate.times 2, :game, start_time: game.start_time + 1.hour }

    it 'stores the league picks on the game' do
      BettableGame.new(game).call
      game.league_picks.should == league_picks
    end
  end

  describe 'assign default pools' do
    let!(:pools) { Fabricate.times 3, :pool, default: true }

    context 'when no pools specified' do
      it 'stores the default pool on the game' do
        BettableGame.new(game).call
        game.pools.should == pools
      end
    end

    context 'when pools are specified' do
      it 'does not override the pools' do
        pool = Fabricate :pool
        game.pools << pool
        BettableGame.new(game).call
        game.pools.should == [pool]
      end
    end
  end

  describe 'create contest templates' do
    let(:pools) { Fabricate.times 2, :pool }
    before { game.pools << pools }

    it 'generates a contest template for each pool' do
      BettableGame.new(game).call
      game.contest_templates.size.should == 2
      game.contest_templates.map(&:pool).should == pools
    end

    it 'generates the best and bust questions' do
      BettableGame.new(game).call!
      game.contest_templates.each do |template|
        template.reload
        best_topics = template.best_questions.map(&:topic_id).sort
        bust_topics = template.bust_questions.map(&:topic_id).sort
        best_topics.should_not == bust_topics
      end
    end

    it 'persists the contest templates when the game is saved' do
      BettableGame.new(game).call
      game.save
      game.contest_templates.each do |ct|
        ct.reload
        ct.should be_persisted
        ct.game.should == game
      end
    end

    it 'does not persist the contest template if the game is not saved (due to validation or whatever else)' do
      BettableGame.new(game).call
      game.contest_templates.each do |ct|
        ct.should_not be_persisted
      end
    end
  end

end