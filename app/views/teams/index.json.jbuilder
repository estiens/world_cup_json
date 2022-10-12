json.groups @groups do |group|
  json.letter group.letter
  json.teams group.teams do |team|
    json.partial! 'teams/result', team: team
  end
end
