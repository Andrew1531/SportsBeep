describe 'Calculating the GameFrame' do
  let(:game) { Fabricate.build :game, start_time: Time.now }

  it 'returns the games in the next 4 hours if there are at least 3' do
    games = Fabricate.times 5, :game, start_time: rand(1..3).hours.from_now
    BettableGame.new(game).call!
    game.league_picks.should == games
  end

  it 'returns a max of 9 games' do
    games = Fabricate.times 10, :game, start_time: 1.hour.from_now
    BettableGame.new(game).call!
    game.league_picks.size.should == 9
  end

  it 'returns a minimum of 3 games, incrementing the interval up 4 hours each time' do
    Fabricate.times 2, :game, start_time: 1.hour.from_now
    Fabricate :game, start_time: 5.hours.from_now
    BettableGame.new(game).call!
    game.league_picks.size.should == 3
  end

  it 'returns ALL games within the extended frame, regardless of the minimum constraint' do
    Fabricate.times 2, :game, start_time: 1.hour.from_now
    Fabricate.times 2, :game, start_time: 5.hours.from_now
    BettableGame.new(game).call!
    game.league_picks.size.should == 4
  end

  it 'stops extending the frame when 3 games are found' do
    Fabricate.times 2, :game, start_time: 1.hour.from_now
    Fabricate.times 2, :game, start_time: 5.hours.from_now
    Fabricate :game, start_time: 10.hours.from_now
    BettableGame.new(game).call!
    game.league_picks.size.should == 4
  end

  it 'does not include a team twice' do
    team = Fabricate :team
    game = Fabricate :game, start_time: Time.current
    Fabricate.times 2, :game, home_team: team, start_time: 1.hour.from_now
    BettableGame.new(game).call!
    game.league_picks.size.should == 1
  end

  it 'stops after searching 3 days ahead' do
    game = Fabricate :game, start_time: 5.days.from_now
    league_picks = Fabricate.times 2, :game, start_time: 6.days.from_now
    excluded = Fabricate :game, start_time: 9.days.from_now
    BettableGame.new(game).call!
    game.league_picks.should == league_picks
  end
end
