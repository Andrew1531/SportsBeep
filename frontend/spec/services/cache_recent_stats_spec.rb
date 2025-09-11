describe Mlb::CacheRecentStats, sport: 'Mlb' do

  describe 'batters' do
    let(:player) { Fabricate :player, position: '1B' }

    describe 'stat that should be totaled' do
      it 'totals each stat in the last 10 games' do
        Fabricate.times 1, :stat, player: player, stat: Mlb::Stats::SINGLES, amount: 100, game: Fabricate(:game, start_time: 10.years.ago)
        Fabricate.times 5, :stat, player: player, stat: Mlb::Stats::SINGLES, amount: 2
        Fabricate.times 5, :stat, player: player, stat: Mlb::Stats::SINGLES, amount: 4
        Mlb::CacheRecentStats.new.perform(player)
        player.recent_stats[Mlb::Stats::SINGLES].should == 30
      end
    end

    describe 'stat that should be averaged' do
      it 'averages each stat in the last 10 games' do
        Fabricate.times 1, :stat, player: player, stat: Mlb::Stats::BATTING_AVERAGE, amount: 100, game: Fabricate(:game, start_time: 10.years.ago)
        Fabricate.times 5, :stat, player: player, stat: Mlb::Stats::BATTING_AVERAGE, amount: 0.234
        Fabricate.times 5, :stat, player: player, stat: Mlb::Stats::BATTING_AVERAGE, amount: 0.567
        Mlb::CacheRecentStats.new.perform(player)
        player.recent_stats[Mlb::Stats::BATTING_AVERAGE].should == 0.4005
      end
    end

    describe 'starting pitchers' do
      let(:player) { Fabricate :player, position: 'SP' }

      it 'should contain SP stats but not RP/CP and batting stats' do
        Fabricate :stat, player: player, stat: Mlb::Stats::LOSSES, amount: 2
        Fabricate :stat, player: player, stat: Mlb::Stats::AT_BATS, amount: 2
        Fabricate :stat, player: player, stat: Mlb::Stats::SAVES, amount: 2
        Mlb::CacheRecentStats.new.perform(player)
        player.recent_stats.size.should == 1
        player.recent_stats[Mlb::Stats::LOSSES].should == 2
      end
    end

    describe 'other pitchers' do
      let(:player) { Fabricate 'Mlb::Player', position: 'RP' }

      it 'should contain RP stats but not SP and batting stats' do
        Fabricate :stat, player: player, stat: Mlb::Stats::LOSSES, amount: 2
        Fabricate :stat, player: player, stat: Mlb::Stats::AT_BATS, amount: 2
        Fabricate :stat, player: player, stat: Mlb::Stats::SAVES, amount: 2
        Mlb::CacheRecentStats.new.perform(player)
        player.recent_stats.size.should == 1
        player.recent_stats[Mlb::Stats::SAVES].should == 2
      end
    end

    describe 'any other player' do
      let(:player) { Fabricate 'Mlb::Player', position: '1B' }

      it 'should contain batting stats and not pitching stats' do
        Fabricate :stat, player: player, stat: Mlb::Stats::LOSSES, amount: 2
        Fabricate :stat, player: player, stat: Mlb::Stats::AT_BATS, amount: 2
        Fabricate :stat, player: player, stat: Mlb::Stats::SAVES, amount: 2
        Mlb::CacheRecentStats.new.perform(player)
        player.recent_stats.size.should == 1
        player.recent_stats[Mlb::Stats::AT_BATS].should == 2
      end
    end

  end

end

describe Nfl::CacheRecentStats, sport: 'Nfl' do

  describe 'kickers' do
    let(:player) { Fabricate :player, position: 'K' }
    let(:stats) do
      [
        Nfl::Stats::FG_0_39_YDS,
        Nfl::Stats::FG_40_49_YDS,
        Nfl::Stats::FG_50_YDS,
        Nfl::Stats::FG_PCT,
        Nfl::Stats::XP_MADE,
        Nfl::Stats::XP_PCT,
      ]
    end

    it 'should include all kicker stats' do
      stats.each { |s| Fabricate :stat, player: player, stat: s, amount: 1 }
      Nfl::CacheRecentStats.new.perform(player)
      stats.each do |s|
        player.recent_stats[s].should == 1.0
      end
    end
  end

  describe 'running backs' do
    let(:player) { Fabricate :player, position: 'RB' }
    let(:stats) do
      [
        Nfl::Stats::RUSHING_YDS,
        Nfl::Stats::RUSHING_TDS,
        Nfl::Stats::RECEIVING_YDS,
        Nfl::Stats::RECEIVING_TDS,
        Nfl::Stats::FUMBLES
      ]
    end

    it 'should include all running back stats' do
      stats.each { |s| Fabricate :stat, player: player, stat: s, amount: 1 }
      Nfl::CacheRecentStats.new.perform(player)
      stats.each do |s|
        player.recent_stats[s].should == 1.0
      end
    end
  end

  describe 'receivers' do
    let(:player) { Fabricate :player, position: 'WR' }
    let(:stats) do
      [
        Nfl::Stats::RECEPTIONS,
        Nfl::Stats::RECEIVING_YDS,
        Nfl::Stats::RECEIVING_TDS,
        Nfl::Stats::FUMBLES
      ]
    end

    it 'should include all running back stats' do
      stats.each { |s| Fabricate :stat, player: player, stat: s, amount: 1 }
      Nfl::CacheRecentStats.new.perform(player)
      stats.each do |s|
        player.recent_stats[s].should == 1.0
      end
    end
  end

end