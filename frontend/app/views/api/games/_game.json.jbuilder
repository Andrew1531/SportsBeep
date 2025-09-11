json.(game, :id)
json.start_time timestamp(game.start_time)

json.home_team { json.partial! 'api/teams/team', team: game.home_team }
json.away_team { json.partial! 'api/teams/team', team: game.away_team }
