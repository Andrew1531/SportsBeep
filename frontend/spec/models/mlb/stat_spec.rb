describe Mlb::Stat, sport: 'Mlb' do

  it 'calculates the points before save for a hitter' do
    player = Fabricate :player, position: '1B'
    Fabricate(:stat, player: player, stat: Mlb::Stats::SINGLES, amount: 5).points.should == 5
    Fabricate(:stat, player: player, stat: Mlb::Stats::DOUBLES, amount: 5).points.should == 10
    Fabricate(:stat, player: player, stat: Mlb::Stats::TRIPLES, amount: 5).points.should == 15
    Fabricate(:stat, player: player, stat: Mlb::Stats::HOME_RUNS, amount: 5).points.should == 20
    Fabricate(:stat, player: player, stat: Mlb::Stats::RUNS, amount: 5).points.should == 5
    Fabricate(:stat, player: player, stat: Mlb::Stats::RBIS, amount: 5).points.should == 5
    Fabricate(:stat, player: player, stat: Mlb::Stats::WALKS, amount: 5).points.should == 5
    Fabricate(:stat, player: player, stat: Mlb::Stats::HIT_BY_PITCH, amount: 5).points.should == 5
    Fabricate(:stat, player: player, stat: Mlb::Stats::STOLEN_BASES, amount: 5).points.should == 10
    Fabricate(:stat, player: player, stat: Mlb::Stats::OUTS, amount: 5).points.should == -1.25
    Fabricate(:stat, player: player, stat: Mlb::Stats::STRIKE_OUTS, amount: 5).points.should == 0
  end

  it 'calculates the points before save for a pitcher' do
    player = Fabricate :player, position: 'SP'
    Fabricate(:stat, player: player, stat: Mlb::Stats::WINS, amount: 5).points.should == 20
    Fabricate(:stat, player: player, stat: Mlb::Stats::ERA, amount: 5).points.should == -5
    Fabricate(:stat, player: player, stat: Mlb::Stats::INNINGS_PITCHED, amount: 5).points.should == 5
    Fabricate(:stat, player: player, stat: Mlb::Stats::STRIKE_OUTS, amount: 5).points.should == 5
    Fabricate(:stat, player: player, stat: Mlb::Stats::HITS_ALLOWED, amount: 5).points.should == -1.25
  end

  describe '.scored' do
    it 'only returns stats that have a point value' do
      nonscored = Fabricate :stat, stat: Mlb::Stats::BATTING_AVERAGE
      scored = [
        Fabricate(:stat, stat: Mlb::Stats::SINGLES),
        Fabricate(:stat, stat: Mlb::Stats::DOUBLES),
        Fabricate(:stat, stat: Mlb::Stats::TRIPLES),
        Fabricate(:stat, stat: Mlb::Stats::HOME_RUNS),
        Fabricate(:stat, stat: Mlb::Stats::RUNS),
        Fabricate(:stat, stat: Mlb::Stats::RBIS),
        Fabricate(:stat, stat: Mlb::Stats::WALKS),
        Fabricate(:stat, stat: Mlb::Stats::HIT_BY_PITCH),
        Fabricate(:stat, stat: Mlb::Stats::STOLEN_BASES),
        Fabricate(:stat, stat: Mlb::Stats::OUTS),
        Fabricate(:stat, stat: Mlb::Stats::WINS),
        Fabricate(:stat, stat: Mlb::Stats::ERA),
        Fabricate(:stat, stat: Mlb::Stats::INNINGS_PITCHED),
        Fabricate(:stat, stat: Mlb::Stats::STRIKE_OUTS),
        Fabricate(:stat, stat: Mlb::Stats::HITS_ALLOWED)
      ]
      Stat.scored(Mlb).should == scored
    end
  end

  describe '#to_s' do
    it 'translates MLB stats', sport: 'Mlb' do
      Fabricate(:stat, stat: Mlb::Stats::BATTING_AVERAGE).to_s.should == 'Batting average'
    end

    it 'translates NFL stats', sport: 'Nfl' do
      Fabricate(:stat, stat: Nfl::Stats::PASSING_TDS).to_s.should == 'Passing TDs'
    end
  end

  describe '#abbr, #multiplier' do
    it 'returns the abbreviation and multiplier of a Scoreable object' do
      stat = Fabricate(:stat, stat: Mlb::Stats::BATTING_AVERAGE)
      stat.abbr.should == 'AVG'
      stat.multiplier.should == 0
    end
  end

end
