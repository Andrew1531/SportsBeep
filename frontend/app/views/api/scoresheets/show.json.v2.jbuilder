json.cache! @stats do
  json.score round(@stats.total)
  json.stats @stats, partial: '/api/resources/stat', as: :stat
end