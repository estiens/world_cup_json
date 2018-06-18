# frozen_string_literal: true

collection @matches, object_root: false
cache "list_matches/#{@matches.pluck(:id).join('')}", expires_in: 15.seconds
attributes :venue, :location, :status, :time, :fifa_id
node :datetime do |match|
  match.datetime&.utc&.iso8601
end
node :last_event_update_at do |match|
  match.last_event_update_at&.utc&.iso8601
end
node :last_score_update_at do |match|
  match.last_score_update_at&.utc&.iso8601
end
node :home_team do |match|
  if match.home_team
    {
      country: match.home_team.country,
      code: match.home_team.fifa_code,
      goals: match.home_team_score
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
      goals: match.away_team_score
    }
  else
    {
      country: 'To Be Determined',
      code: 'TBD',
      team_tbd: match.away_team_tbd
    }
  end
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
node :home_team_events do |match|
  begin
    events = match.home_team_events
    return nil unless events
    events.select('id, type_of_event, player, time').sort_by { |e| e.time.to_i }
  rescue StandardError
    'no events available for this match'
  end
end
node :away_team_events do |match|
  begin
    events = match.away_team_events
    return nil unless events
    events.select('id, type_of_event, player, time').sort_by { |e| e.time.to_i }
  rescue StandardError
    'no events available for this match'
  end
end
child home_stats: :home_team_statistics do |ms|
  node(:country) { ms.team.country }
  attributes :attempts_on_goal, :on_target, :off_target, :blocked, :woodwork,
             :corners, :offsides, :ball_possession, :pass_accuracy, :num_passes,
             :passes_completed, :distance_covered, :balls_recovered, :tackles,
             :clearances, :yellow_cards, :red_cards, :fouls_committed
end
child away_stats: :away_team_statistics do |ms|
  node(:country) { ms.team.country }
  attributes :attempts_on_goal, :on_target, :off_target, :blocked, :woodwork,
             :corners, :offsides, :ball_possession, :pass_accuracy, :num_passes,
             :passes_completed, :distance_covered, :balls_recovered, :tackles,
             :clearances, :yellow_cards, :red_cards, :fouls_committed
end
