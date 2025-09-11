json.cache! stat do
  json.name stat.to_s
  json.abbr stat.abbr

  json.amount stat.format(:amount)
  json.points stat.format(:points)

  json.points_per stat.multiplier.to_s
end