json.cache_collection! @groups, expires_in: 1.minute do |group|
  json.partial! '/teams/group_result', group: group
end
