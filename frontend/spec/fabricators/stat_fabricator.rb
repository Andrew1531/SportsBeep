Fabricator(:stat) do
  player
  game
  team
  amount { rand(1..5) }
  points nil
  type { ENV['SPORT'] && "#{ENV['SPORT']}::Stat" }

  stat do
    case ENV['SPORT']
    when 'Mlb'
      [Mlb::Stats::SINGLES, Mlb::Stats::DOUBLES, Mlb::Stats::TRIPLES, Mlb::Stats::HOME_RUNS].sample.id
    when 'Nfl'
      [Nfl::Stats::RECEPTIONS, Nfl::Stats::RUSHING_ATTEMPTS, Nfl::Stats::FUMBLES, Nfl::Stats::TOUCHDOWNS].sample.id
    end
  end

  after_create do |stat|
    UpdateCachedTicketScores.new.perform(stat.game)
  end

end