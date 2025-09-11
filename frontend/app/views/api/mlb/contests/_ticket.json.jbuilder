if ticket

  json.(ticket, :id)
  json.score round(ticket.score)
  json.prize_pool ticket.pool.prize_pool
  json.placing ticket.placing

  json.user do
    json.username ticket.user.username
  end

end
