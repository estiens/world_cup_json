json.cache_collection! @matches, expires_in: @cache_time do
  json.array! @matches, partial: '/matches/match', as: :match
end
