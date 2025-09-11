json.players @players do |player|
  json.(player, :id, :name, :number)
  json.position player.position_in(@game)

  json.season_stats(player.seasonal_stats.where(name: Mlb::EXPANDED_STATS_FOR.(player))) do |stat|
    json.name   st(stat.name)
    json.abbr   stat.name.upcase
    json.amount format_stat stat.amount, stat.name
  end

  json.recent_stats(player.recent_stats.where(name: Mlb::EXPANDED_STATS_FOR.(player))) do |stat|
    json.name   st(stat.name)
    json.abbr   stat.name.upcase
    json.amount format_stat stat.amount, stat.name
  end

  json.team do
    json.(player.team, :id)
  end
end