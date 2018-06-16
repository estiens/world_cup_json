collection @groups
attributes :id, :letter
child :ordered_teams do
  attributes :id, :country, :fifa_code
  node(:points, &:team_points)
  node(:goal_differential, &:team_goal_differential)
end
