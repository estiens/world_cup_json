json.cache_collection! @teams, expires_in: 1.minute do
  json.array! @teams, partial: '/teams/result', as: :team
end
