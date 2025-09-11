class Nfl::QuarterbackSquad < Nfl::Squad
  QUARTERBACK_STATS = [
    Nfl::Stats::PASSING_TDS.id,
    Nfl::Stats::PASSING_YDS.id,
    Nfl::Stats::RUSHING_YDS.id,
    Nfl::Stats::RUSHING_TDS.id,
    Nfl::Stats::PASSING_INT.id,
    Nfl::Stats::FUMBLES.id
  ]

  def name
    'quarterbacks'
  end

  def stats
    @_stats ||= @stats.joins(:player).where(players: { position: 'QB' }, stat: QUARTERBACK_STATS)
  end
end