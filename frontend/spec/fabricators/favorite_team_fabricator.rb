Fabricator(:favorite_team) do
  user
  baseball fabricator: 'Mlb::Team'
end
