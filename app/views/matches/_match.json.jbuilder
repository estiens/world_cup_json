# frozen_string_literal: true

json.call(match, :venue, :location, :status, :fifa_id, :weather, :attendance, :officials, :stage_name)

json.home_team_country match.home_team&.country
json.away_team_country match.away_team&.country
json.datetime match.datetime&.utc&.iso8601

if match.draw
  json.winner 'Draw'
  json.winner_code 'Draw'
else
  json.winner match.winner&.country
  json.winner_code match.winner&.fifa_code
end
json.home_team do
  if match.home_team
    json.country match.home_team.country
    json.code match.home_team.fifa_code
    json.goals match.home_team_score
    json.penalties match.home_team_penalties
  else
    json.country 'To Be Determined'
    json.code 'TBD'
    json.team_tbd match.home_team_tbd
  end
end
json.away_team do
  if match.away_team
    json.country match.away_team.country
    json.code match.away_team.fifa_code
    json.goals match.away_team_score
    json.penalties match.away_team_penalties
  else
    json.country 'To Be Determined'
    json.code 'TBD'
    json.team_tbd match.away_team_tbd
  end
end
unless @summary
  json.time match.time
  json.current_match_time match.detailed_time
  json.home_team_events do
    if match.home_team
      events = match.home_team_events.sort_by { |e| e.time.to_i }
      json.array! events do |event|
        json.id event.id
        json.type_of_event event.type_of_event
        json.player event.player
        json.time event.time
      end
    else
      []
    end
  end

  json.away_team_events do
    if match.away_team
      events = match.away_team_events.sort_by { |e| e.time.to_i }
      json.array! events do |event|
        json.id event.id
        json.type_of_event event.type_of_event
        json.player event.player
        json.time event.time
      end
    else
      []
    end
  end

  json.home_team_statistics do
    if match.home_stats
      json.country match.home_team.country
      json.call(match.home_stats, :attempts_on_goal, :on_target, :off_target, :blocked,
                :corners, :offsides, :ball_possession, :pass_accuracy, :num_passes,
                :passes_completed, :distance_covered, :tackles,
                :clearances, :yellow_cards, :red_cards, :fouls_committed, :tactics,
                :starting_eleven, :substitutes)
    else
      []
    end
  end

  json.away_team_statistics do
    if match.away_stats
      json.country match.away_team.country
      json.call(match.away_stats, :attempts_on_goal, :on_target, :off_target, :blocked,
                :corners, :offsides, :ball_possession, :pass_accuracy, :num_passes,
                :passes_completed, :distance_covered, :tackles,
                :clearances, :yellow_cards, :red_cards, :fouls_committed, :tactics,
                :starting_eleven, :substitutes)
    else
      []
    end
  end
end

json.last_checked_at match.last_checked_at&.utc&.iso8601
json.last_changed_at match.last_changed_at&.utc&.iso8601
