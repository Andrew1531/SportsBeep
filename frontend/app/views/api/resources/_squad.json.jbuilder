json.id squad.team_id
json.game_position squad.position
json.team do
  json.partial! 'api/resources/team', team: squad.team
end
json.score TwoDecimalsMaximumRounded.new.format(squad.score)