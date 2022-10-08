json.call(@team, :id, :country)
json.name @team.alternate_name
json.wins @team.team_wins
json.draws @team.team_draws
json.losses @team.team_losses
json.games_played @team.games_played
json.group_points @team.team_points
json.goals_for @team.team_goals_for
json.goals_against @team.team_goals_against
json.goal_differential @team.team_goal_differential
if @last_match
  json.last_match @last_match do
    json.partial! 'matches/result', match: @last_match
  end
end
if @next_match
  json.next_match do
    json.home_team @next_match.home_team&.country || @next_match.home_team_tbd
    json.away_team @next_match.away_team&.country || @next_match.away_team_tbd
  end
end
