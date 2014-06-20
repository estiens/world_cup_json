collection @groups
attributes :letter
child :ordered_teams do |team|
attributes :country, :fifa_code
node :points do |team|
  team.team_points
end
node :goal_differential do |team|
  team.goal_differential
end
end