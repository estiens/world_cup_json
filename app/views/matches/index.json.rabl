collection @matches, object_root: false
attributes :match_number, :location, :datetime, :status
node :home_team do |match|
  if match.home_team
    {country: match.home_team.country, code: match.home_team.fifa_code, goals: match.home_team_score}
  else
    {country: "to be determined", code: "TBD"}
    attribute :home_team_tbd
  end
end
node :away_team do |match|
  if match.away_team
    {country: match.away_team.country, code: match.away_team.fifa_code, goals: match.away_team_score}
  else
    {country: "to be determined", code: "TBD"}
    attribute :away_team_tbd
  end
end
node :winner do |match|
  if match.status == "completed"
    if match.home_team_score > match.away_team_score
      match.home_team.country
    elsif match.home_team_score < match.away_team_score
      match.away_team.country
    else
      "Draw"
    end
  end
end




