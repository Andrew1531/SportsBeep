json.rankings @rankings do |ranking|
  json.(ranking, :name, :rank)
  json.value ranking.stat.format(:amount)
end