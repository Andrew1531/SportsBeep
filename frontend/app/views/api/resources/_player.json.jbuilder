json.cache! ['v2', player] do
  json.(player, :id, :name, :number, :headshot_url)
  json.position player.position_in(@game)
  json.stats stats_to_display_under(player), partial: 'api/resources/stat', as: :stat
  json.team do
    json.id player.team.try(:id)
  end
end

if @ticket
  json.game_position @ticket.ticket_players.find_by(player: player).position
  json.score round(player.stats.scored(current_sport).where(game: @ticket.game).total)
end
