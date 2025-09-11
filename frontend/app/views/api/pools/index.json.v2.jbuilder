json.cache! @pools do
  json.pools @pools, partial: 'api/resources/pool', as: :pool
end
