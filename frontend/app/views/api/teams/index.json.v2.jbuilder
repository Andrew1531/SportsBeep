json.cache! @teams do
  json.teams @teams, partial: 'api/resources/team', as: :team
end
