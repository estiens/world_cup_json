collection @teams, object_root: false
attributes :id, :country, :alternate_name, :fifa_code, :group_id
node :group_letter do |team|
  team.group.letter
end
node :wins, &:team_wins
node :draws, &:team_draws
node :losses, &:team_losses
node :games_played, &:games_played
node :points, &:team_points
node :goals_for, &:team_goals_for
node :goals_against, &:team_goals_against
node :goal_differential, &:team_goal_differential
