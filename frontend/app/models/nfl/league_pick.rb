class Nfl::LeaguePick < LeaguePick

  def score
    return 0 unless game && team
    return 0 if game.status?(:postponed) || game.status?(:suspended)
    game.stats.where(name: :td, team: team).sum(:amount) * 3
  end

  def rankings
    []
  end

  private

    def stats
      @_stats ||= game.stats.where(name: :td, team: team).where('amount > ?', 0)
    end

    def season_total_for(player)
      season_td = player.seasonal_stats.fetch(:td)
      game_td   = stats.where(player: player).sum(:amount)

      if season_td && season_td.updated_at < game.start_time
        (season_td.try(:amount) || 0) + game_td
      else
        season_td.try(:amount) || 0
      end
    end

end