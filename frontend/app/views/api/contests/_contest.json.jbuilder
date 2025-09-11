json.(contest, :id)
json.tickets do
  json.array! [contest.tickets.find_by(user: current_user)] do |ticket|
    json.partial! 'api/contests/ticket', ticket: ticket
  end
end

json.game do
  json.partial! 'api/games/game', game: contest.game
end
