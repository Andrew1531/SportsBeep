json.cache! game do
  json.(game, :id)
  json.start_time timestamp(game.start_time)

  json.home_team do
    json.partial! 'api/resources/team', team: game.home_team
  end

  json.away_team do
    json.partial! 'api/resources/team', team: game.away_team
  end
end