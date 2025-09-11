json.(ticket, :id)
json.score round(ticket.score)

json.players ticket.players do |player|
  json.(player, :id, :name, :position)
  json.game_position ticket.ticket_players.find_by(player: player).position
  player.stats.scored(current_sport).where(game: ticket.game).tap do |stats|
    json.score round(stats.total)
    json.breakdown stats, partial: '/api/tickets/stat', as: :stat
  end
end

json.contest do
  json.id ticket.contest.id
end

json.best_or_bust_score round(ticket.answers.score)

json.league_pick do
  json.score round(ticket.league_pick.try :score)

  json.game do
    json.id ticket.league_pick_game.try :id
  end

  json.team do
    json.id ticket.league_pick_team.try :id
  end
end
