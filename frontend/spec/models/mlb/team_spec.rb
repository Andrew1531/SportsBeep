describe Team, sport: 'Mlb' do

  describe 'average home runs per game' do
    let(:team) { Fabricate :team }

    it 'calculates the average home runs per game' do
      team.stats.create(stat: Mlb::Stats::HOME_RUNS, amount: 12)
      team.stats.create(stat: Mlb::Stats::GAMES, amount: 5)
      team.average_hr_per_game.should == 2.4
    end
  end

end
