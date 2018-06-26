json.cache_collection! @groups, expires_in: 1.minute do
  json.array! @groups, partial: '/teams/group_result', as: :group
end
