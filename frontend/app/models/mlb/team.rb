class Mlb::Team < Team

  NONSTANDARD_TEAMS = ['Retired', 'National League', 'Unknown Team', 'American League', 'Minor League']

  validates :league, inclusion: { in: %w(NL AL) }, allow_blank: true

  def self.standard
    where.not(name: NONSTANDARD_TEAMS)
  end

  def wins
    stats[Mlb::Stats::WINS]
  end

  def losses
    stats[Mlb::Stats::LOSSES]
  end

  def league_pick_stat
    average_hr_per_game
  end

  # keep for v1 compatibility
  def average_hr_per_game
    games = stats[Mlb::Stats::GAMES]
    (games.zero?) ? 0 : stats[Mlb::Stats::HOME_RUNS].fdiv(games)
  end

  def rankings
    [Mlb::Stats::RUNS, Mlb::Stats::BATTING_AVERAGE, Mlb::Stats::ON_BASE_PCT, Mlb::Stats::SLUGGING_PCT].map do |statdata|
      ranking = Ranking.new
      ranking.stat = stats.fetch(statdata)
      ranking.rank! TeamStat.sport('Mlb').where(stat: statdata.id).pluck(:amount)
      ranking
    end
  end

end
