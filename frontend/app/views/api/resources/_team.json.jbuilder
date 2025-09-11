json.cache! ['v3', team] do
  json.(team, :id, :market, :name, :abbr)
  json.wins   format_stat team.wins
  json.losses format_stat team.losses
  json.league_pick_stat format_stat team.league_pick_stat
  json.primary_color "##{team.primary_color}"
  json.secondary_color "##{team.secondary_color}"
end