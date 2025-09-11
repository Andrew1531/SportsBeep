Fabricator(:team_stat) do
  team   nil
  season 1
  amount 1.5

  stat do
    case ENV['SPORT']
    when 'Mlb'
      [Mlb::Stats::SINGLES, Mlb::Stats::DOUBLES, Mlb::Stats::TRIPLES, Mlb::Stats::HOME_RUNS].sample.id
    when 'Nfl'
      [Nfl::Stats::RECEPTIONS, Nfl::Stats::RUSHING_ATTEMPTS, Nfl::Stats::FUMBLES, Nfl::Stats::TOUCHDOWNS].sample.id
    end
  end

end
