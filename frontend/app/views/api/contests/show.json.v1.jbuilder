json.(@contest, :id)

json.game do
  json.partial! 'api/games/game', game: @contest.game
end

json.tickets @tickets, partial: 'api/contests/ticket', as: :ticket