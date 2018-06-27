json.(match, :venue, :location, :status, :time, :fifa_id,
             :weather, :attendance, :officials, :stage_name)

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
     json.penalties match.json_home_team_penalties
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
     json.penalties match.json_away_team_penalties
  else
    json.country 'To Be Determined'
    json.code 'TBD'
    json.team_tbd match.away_team_tbd
  end
end
unless @summary
  json.home_team_events do
    if match.home_team
      json.cache! [match.fifa_id, match.home_team, match.home_team.events], expires_in: @cache_time do
      events = match.home_team_events.sort_by { |e| e.time.to_i }
        json.array! events do |event|
          json.id event.id
          json.type_of_event event.type_of_event
          json.player event.player
          json.time event.time
        end
      end
    else
      []
    end
  end

  json.away_team_events do
    if match.away_team
      json.cache! [match.fifa_id, match.away_team, match.away_team.events], expires_in: @cache_time do
        events = match.away_team_events.sort_by { |e| e.time.to_i }
        json.array! events do |event|
          json.id event.id
          json.type_of_event event.type_of_event
          json.player event.player
          json.time event.time
        end
      end
    else
      []
    end
  end

  json.home_team_statistics do
    if match.home_stats
      json.partial! '/matches/stats', stats: match.home_stats
    else
      []
    end
  end

  json.away_team_statistics do
    if match.away_stats
      json.partial! '/matches/stats', stats: match.away_stats
    else
      []
    end
  end
end

json.last_event_update_at match.last_event_update_at&.utc&.iso8601
json.last_score_update_at match.last_score_update_at&.utc&.iso8601
