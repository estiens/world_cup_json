json.id group.id
json.letter group.letter
json.ordered_teams do
  json.cache! [group, group.ordered_teams], expires_in: 1.minute do
    json.array! group.ordered_teams, partial: '/teams/result', as: :team
  end
end
