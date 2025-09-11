json.cache! [@games, Team.all] do
  json.games @games, partial: 'api/resources/game', as: :game
end
