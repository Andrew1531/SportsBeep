json.amount OneDecimalOrWhole.new.format league_pick.amount
json.score  OneDecimalOrWhole.new.format league_pick.score

json.scorers league_pick.scorers do |scorer|
  json.(scorer, :name)
  json.season_total OneDecimalOrWhole.new.format(scorer.season_total)
end

json.team do
  json.id league_pick.team.try(:id)
end

json.game do
  json.id league_pick.game.try(:id)
end