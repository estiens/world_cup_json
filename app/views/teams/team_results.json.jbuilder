json.cache_collection! @teams, expires_in: 1.minute do |team|
  json.partial! 'teams/result', team: team
end
