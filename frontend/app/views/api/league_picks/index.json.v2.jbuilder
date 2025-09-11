json.cache! @game do
  json.games @league_picks, partial: 'api/resources/game', as: :game
end
