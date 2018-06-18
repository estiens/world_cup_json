collection @groups
cache "groups/#{@groups.pluck(:id).join('')}", expires_in: 1.minute
attributes :id, :letter
child :ordered_teams do
  attributes :id, :country, :fifa_code
  node(:points, &:team_points)
  node(:wins, &:team_wins)
  node(:draws, &:team_draws)
  node(:losses, &:team_losses)
  node(:games_played, &:games_played)
  node(:points, &:team_points)
  node(:goals_for, &:team_goals_for)
  node(:goals_against, &:team_goals_against)
  node(:goal_differential, &:team_goal_differential)
end
