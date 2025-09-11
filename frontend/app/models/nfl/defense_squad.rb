class Nfl::DefenseSquad < Nfl::Squad
  DEFENSE_STATS = [
    Nfl::Stats::SACKS.id,
    Nfl::Stats::DEFENSE_INT.id,
    Nfl::Stats::FUMBLES_RECOVERED.id,
    Nfl::Stats::SAFETIES.id,
    Nfl::Stats::BLOCKS.id
  ]

  def name
    'defense'
  end

  def stats
    @_stats ||= @stats.where(stat: DEFENSE_STATS)
  end
end