json.(ticket, :id)
json.score round(ticket.score)
json.prize_pool ticket.pool.prize_pool
json.placing ticket.placing

json.cache! Time.now.to_s(:nsec) do
  json.editable ticket.editable_by?(current_user)
  json.visible_to_others !(ticket.game.upcoming? && ticket.user != current_user)
end

json.user do
  json.username ticket.user.username
  if ticket.user.avatar_processing?
    json.avatar_url ticket.user.avatar.url
  else
    json.avatar_url ticket.user.avatar.url(avatar_size)
  end
end

json.contest do
  json.id ticket.contest.id
end

json.best_or_bust_score round(ticket.best_or_bust_score)

# League picks were removed
unless ticket.league_pick.nil?
  json.league_pick do
    json.score round(ticket.league_pick.try :score)

    json.game do
      json.id ticket.league_pick_game.try :id
    end

    json.team do
      json.id ticket.league_pick_team.try :id
    end
  end
end
