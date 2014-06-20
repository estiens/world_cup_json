collection @teams, object_root: false
attributes :country, :alternate_name, :fifa_code, :group_id
node :wins do |team|
  team.team_wins
end
node :draws do |team|
  team.team_draws
end
node :losses do |team|
  team.team_losses
end
node :games_played do |team|
  team.games_played
end
node :points do |team|
  team.team_points
end
node :goals_for do |team|
  team.team_goals_for
end
node :goals_against do |team|
  team.team_goals_against
end
node :goal_differential do |team|
  team.goal_differential
end
