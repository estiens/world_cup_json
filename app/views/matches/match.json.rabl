object @match
cache @match, expires_in: @cache_time
attributes :venue, :location, :status, :time, :fifa_id, :weather, :attendance, :officials, :stage_name

node :home_team_country do |match|
  match.home_team&.country
end

node :away_team_country do |match|
  match.away_team&.country
end

node :datetime do |match|
  match.datetime&.utc&.iso8601
end

node :winner do |match|
  if match.winner
    match.winner.country
  elsif match.draw
    'Draw'
  end
end

node :winner_code do |match|
  if match.winner
    match.winner.fifa_code
  elsif match.draw
    'Draw'
  end
end

node :home_team do |match|
  if match.home_team
    {
      country: match.home_team.country,
      code: match.home_team.fifa_code,
      goals: match.home_team_score,
      penalties: match.json_home_team_penalties
    }
  else
    {
      country: 'To Be Determined',
      code: 'TBD',
      team_tbd: match.home_team_tbd
    }
  end
end

node :away_team do |match|
  if match.away_team
    {
      country: match.away_team.country,
      code: match.away_team.fifa_code,
      goals: match.away_team_score,
      penalties: match.json_away_team_penalties
    }
  else
    {
      country: 'To Be Determined',
      code: 'TBD',
      team_tbd: match.away_team_tbd
    }
  end
end

node :home_team_events do |match|
  events = match.home_team_events
  if events
    object = events.sort_by { |e| e.time.to_i }
    partial('matches/events', object: object)
  else
    nil
  end
end

node :away_team_events do |match|
  events = match.away_team_events
  if events
    object = events.sort_by { |e| e.time.to_i }
    partial('matches/events', object: object)
  else
    nil
  end
end

child home_stats: :home_team_statistics do
  extends "matches/match_statistics"
end

child away_stats: :away_team_statistics do
  extends "matches/match_statistics"
end

node :last_event_update_at do |match|
  match.last_event_update_at&.utc&.iso8601
end

node :last_score_update_at do |match|
  match.last_score_update_at&.utc&.iso8601
end
