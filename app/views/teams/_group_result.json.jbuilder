json.id group.id
json.letter group.letter
json.ordered_teams do
  json.array! group.ordered_teams, partial: '/teams/result', as: :team
end
