json.(team, :id, :market, :name, :abbr)
json.wins   format_stat team.stats[Mlb::Stats::WINS]
json.losses format_stat team.stats[Mlb::Stats::LOSSES]
json.average_hr_per_game format_stat team.average_hr_per_game
json.primary_color "##{team.primary_color}"
json.secondary_color "##{team.secondary_color}"