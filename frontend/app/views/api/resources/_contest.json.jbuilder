json.(contest, :id)

json.game do
  json.partial! 'api/resources/game', game: contest.game
end
