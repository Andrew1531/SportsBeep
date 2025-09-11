class Nfl::SpecialTeamsSquad < Nfl::Squad
  SPECIAL_TEAMS_STATS = [
    Nfl::Stats::PUNT_RETURN_YDS.id,
    Nfl::Stats::KICK_RETURN_YDS.id,
  ]

  def name
    'special_teams'
  end

  def stats
    @_stats ||= @stats.where(stat: SPECIAL_TEAMS_STATS)
  end
end