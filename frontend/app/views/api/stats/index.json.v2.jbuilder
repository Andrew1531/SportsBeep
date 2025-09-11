json.cache! @season_stats do
  json.season_stats @season_stats, partial: 'api/resources/stat', as: :stat
end

json.cache! @recent_stats do
  json.recent_stats @recent_stats, partial: 'api/resources/stat', as: :stat
end