json.cache! ['v2', @players, (@ticket || @game)] do
  json.players @players, partial: 'api/resources/player', as: :player
end

json.squads @squads, partial: 'api/resources/squad', as: :squad if @squads