Fabricator(:game) do
  transient :league_pick_count
  transient :as_bettable

  external_id { SecureRandom.hex }
  bettable    false
  start_time  { rand(24..48).hours.from_now }
  status      ''
  home_team   fabricator: :team
  away_team   fabricator: :team
  pools       count: 1, fabricator: :pool
  type        { ENV['SPORT'] && "#{ENV['SPORT']}::Game" }

  after_create do |game, transients|
    if lpc = transients[:league_pick_count]
      league_picks = Fabricate.times lpc, :game, start_time: (game.start_time + 3.hours)
      BettableGame.new(game).call!
    end

    if transients[:as_bettable]
      BettableGame.new(game).call!
    end
  end
end