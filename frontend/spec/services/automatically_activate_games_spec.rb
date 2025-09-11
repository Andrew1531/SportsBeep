describe AutomaticallyActivateGames, sport: 'Mlb' do
  it 'loops through the games within the next 48 hours' do
    games = [
      Fabricate(:game, start_time: 5.minutes.from_now),
      Fabricate(:game, start_time: 47.hours.from_now),
      Fabricate(:game, start_time: 49.hours.from_now)
    ]

    games.each { |game| game.should_not be_bettable }
    subject.perform
    games.first(2).each { |game| game.reload.should be_bettable }
    games.last.reload.should_not be_bettable
  end
end

describe AutomaticallyActivateGames, sport: 'Nfl' do
  it 'loops through the games within the next 7 days' do
    games = [
      Fabricate(:game, start_time: 5.minutes.from_now),
      Fabricate(:game, start_time: 6.days.from_now),
      Fabricate(:game, start_time: 15.days.from_now)
    ]

    games.each { |game| game.should_not be_bettable }
    subject.perform
    games.first(2).each { |game| game.reload.should be_bettable }
    games.last.reload.should_not be_bettable
  end
end