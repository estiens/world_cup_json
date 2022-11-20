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
  json.last_match do
    json.id @last_match.id
    json.home_team @last_match.home_team&.country || @last_match.home_team_tbd
    json.away_team @last_match.away_team&.country || @last_match.away_team_tbd
    json.datetime @last_match.datetime&.utc&.iso8601
    json.venue @last_match.venue
    json.location @last_match.location
    json.stage_name @last_match.stage_name
    json.home_team_score @last_match.home_team_score
    json.home_team_penalties @last_match.home_team_penalties
    json.away_team_score @last_match.away_team_score
    json.away_team_penalties @last_match.away_team_penalties
    json.winner @last_match.winner&.country
    json.draw @last_match.draw
  end
end
# if @last_match
#   json.last_match @last_match do
#     json.call(@last_match, :id, :venue, :location, :status, :attendance, :officials, :stage_name)

#     json.home_team_country @last_match.match.home_team&.country
#     json.away_team_country @last_match.match.away_team&.country
#     json.datetime @last_match.match.datetime&.utc&.iso8601

#     if match.draw
#       json.winner 'Draw'
#       json.winner_code 'DRW'
#     else
#       json.winner @last_match.winner&.alternate_name
#       json.winner_code @last_match.winner&.country
#     end
#   end
# end
if @next_match
  json.next_match do
    json.id @next_match.id
    json.home_team @next_match.home_team&.country || @next_match.home_team_tbd
    json.away_team @next_match.away_team&.country || @next_match.away_team_tbd
    json.datetime @next_match.datetime&.utc&.iso8601
    json.venue @next_match.venue
    json.location @next_match.location
    json.stage_name @next_match.stage_name
  end
end
