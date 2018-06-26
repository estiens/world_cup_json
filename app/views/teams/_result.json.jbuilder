json.cache! team, expires_in: 1.minute do
  json.(team, :id, :country, :alternate_name, :fifa_code, :group_id)
  json.group_letter team.group.letter
  json.wins team.team_wins
  json.draws team.team_draws
  json.losses team.team_losses
  json.games_played team.games_played
  json.points team.team_points
  json.goals_for team.team_goals_for
  json.goals_against team.team_goals_against
  json.goal_differential team.team_goal_differential
end
