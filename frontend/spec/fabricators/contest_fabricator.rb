Fabricator(:contest) do
  transient :game
  transient :user
  type { ENV['SPORT'] && "#{ENV['SPORT']}::Contest" }

  template do |attrs|
    Fabricate :contest_template, game: (attrs[:game] || Fabricate(:game))
  end

  after_create do |contest, transients|
    if user = transients[:user]
      Fabricate :ticket, user: user, pool: contest.pool, game: contest.game
    end
  end

end