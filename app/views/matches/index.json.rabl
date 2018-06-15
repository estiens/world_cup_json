collection @matches, object_root: false
attributes :venue, :location, :datetime, :status, :time, :fifa_id
node :home_team do |match|
  if match.home_team_penalties
      {country: match.home_team.country, code: match.home_team.fifa_code, goals: match.home_team_score, penalties: match.home_team_penalties}
  elsif match.home_team
    {country: match.home_team.country, code: match.home_team.fifa_code, goals: match.home_team_score}
  else
    {country: "To Be Determined", code: "TBD", team_tbd: match.home_team_tbd}
  end
end
node :away_team do |match|
  if match.away_team_penalties
      {country: match.away_team.country, code: match.away_team.fifa_code, goals: match.away_team_score, penalties: match.away_team_penalties}
  elsif match.away_team
    {country: match.away_team.country, code: match.away_team.fifa_code, goals: match.away_team_score}
  else
    {country: "To Be Determined", code: "TBD", team_tbd: match.away_team_tbd}
  end
end
node :winner do |match|
  if match.status == "completed"
    if match.home_team_penalties && match.home_team_penalties > match.away_team_penalties
      match.home_team.country
    elsif match.home_team_penalties && match.home_team_penalties < match.away_team_penalties
      match.away_team.country
    elsif match.home_team_score > match.away_team_score
      match.home_team.country
    elsif match.home_team_score < match.away_team_score
      match.away_team.country
    else
      "Draw"
    end
  end
end
node :winner_code do |match|
  if match.status == "completed"
    if match.home_team_penalties && match.home_team_penalties > match.away_team_penalties
      match.home_team.fifa_code
    elsif match.home_team_penalties && match.home_team_penalties < match.away_team_penalties
      match.away_team.fifa_code
    elsif match.home_team_score > match.away_team_score
      match.home_team.fifa_code
    elsif match.home_team_score < match.away_team_score
      match.away_team.fifa_code
    else
      "Draw"
    end
  end
end
node :home_team_events do |match|
  begin
    match.home_team.events.where("match_id = ?",match.id).select("id, type_of_event, player, time").sort_by { |e| e.time.to_i }
  rescue
    "no events available for this match"
  end
end
node :away_team_events do |match|
  begin
    match.away_team.events.where("match_id = ?",match.id).select("id, type_of_event, player, time").sort_by { |e| e.time.to_i }
  rescue
    "no events available for this match"
  end
end
