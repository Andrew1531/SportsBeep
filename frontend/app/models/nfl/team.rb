class Nfl::Team < Team

  def self.standard
    all
  end

  def wins
    stats[Nfl::Stats::WINS]
  end

  def losses
    stats[Nfl::Stats::LOSSES]
  end

  def league_pick_stat
    # average td per game?
    # games = stats[:games]
    # (games.zero?) ? 0 : stats[:td].fdiv(games)
    0
  end

  def rankings
    [Nfl::Stats::OFFENSIVE_YPG, Nfl::Stats::PASSING_YPG, Nfl::Stats::RUSHING_YPG, Nfl::Stats::INTERCEPTIONS_PG].map do |statdata|
      ranking = Ranking.new
      ranking.stat = stats.fetch(statdata)
      ranking.rank! TeamStat.sport('Nfl').where(stat: statdata.id).pluck(:amount)
      ranking
    end
  end

end
