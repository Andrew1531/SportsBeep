class Mlb::LeaguePick < LeaguePick

  def score
    return 0 unless game && team
    return 0 if game.status?(:postponed) || game.status?(:suspended)
    amount * 3
  end

  private

    def stats
      @_stats ||= if game
        game.stats.where(stat: Mlb::Stats::HOME_RUNS.id, team: team).where('amount > ?', 0)
      else
        Mlb::Stat.none
      end
    end

    def season_total_for(player)
      game_hr   = stats.where(player: player).sum(:amount)
      season_hr = player.seasonal_stats.fetch(Mlb::Stats::HOME_RUNS)
      if season_hr && season_hr.updated_at < game.start_time
        (season_hr.try(:amount) || 0) + game_hr
      else
        season_hr.try(:amount) || 0
      end
    end

end