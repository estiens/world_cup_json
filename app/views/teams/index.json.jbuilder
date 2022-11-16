json.groups @groups do |group|
  json.letter group.letter
  json.teams group.teams, partial: 'teams/result', as: :team, cached: true
end
