json.array! @matches, partial: 'matches/match', as: :match do
  json.call(match, :id, :venue, :location, :status, :attendance, :stage_name)

  json.home_team_country match.home_team&.country
  json.away_team_country match.away_team&.country
  json.datetime match.datetime&.utc&.iso8601

  if match.draw
    json.winner 'Draw'
    json.winner_code 'Draw'
  else
    json.winner match.winner&.alternate_name
    json.winner_code match.winner&.country
  end
  json.home_team do
    if match.home_team
      json.country match.home_team.country
      json.name match.home_team.alternate_name
      json.goals match.home_team_score
      json.penalties match.home_team_penalties
    else
      json.name 'To Be Determined'
      json.country match.home_team_tbd
    end
  end
  json.away_team do
    if match.away_team
      json.country match.away_team.country
      json.name match.away_team.alternate_name
      json.goals match.away_team_score
      json.penalties match.away_team_penalties
    else
      json.name 'To Be Determined'
      json.country match.away_team_tbd
    end
  end
  if @details
    json.weather match.weather
    json.time match.completed? ? 'full-time' : match.time
    json.detailed_time match.detailed_time
    json.officials match.officials
    json.home_team_events do
      json.array! match.home_team_events do |event|
        json.id event.id
        json.type_of_event event.type_of_event
        json.player event.player
        json.time event.time
        json.extra_info event.respond_to?(:extra_info) ? event.extra_info : {}
      end
    end

    json.away_team_events do
      json.array! match.away_team_events do |event|
        json.id event.id
        json.type_of_event event.type_of_event
        json.player event.player
        json.time event.time
        json.extra_info event.respond_to?(:extra_info) ? event.extra_info : {}
      end
    end

    json.home_team_lineup do
      if match.home_stats
        json.country match.home_team.country
        json.tactics match.home_stats.tactics
        json.starting_eleven(match.home_stats.starting_eleven&.map { |h| h.slice('name', 'shirt_number', 'position') })
        json.substitutes(match.home_stats.substitutes&.map { |h| h.slice('name', 'shirt_number', 'position') })
      else
        []
      end
    end

    json.away_team_lineup do
      if match.away_stats
        json.country match.away_team.country
        json.tactics match.away_stats.tactics
        json.starting_eleven(match.away_stats.starting_eleven&.map { |h| h.slice('name', 'shirt_number', 'position') })
        json.substitutes(match.away_stats.substitutes&.map { |h| h.slice('name', 'shirt_number', 'position') })
      else
        []
      end
    end

    json.home_team_statistics do
      if match.home_stats
        json.country match.home_team.country
        json.call(match.home_stats,
                  :attempts_on_goal, :on_target, :off_target, :blocked,
                  :corners, :offsides, :ball_possession, :pass_accuracy, :num_passes,
                  :passes_completed, :distance_covered, :tackles,
                  :clearances, :yellow_cards, :red_cards, :fouls_committed)
      else
        []
      end
    end

    json.away_team_statistics do
      if match.away_stats
        json.country match.away_team.country
        json.call(match.away_stats,
                  :attempts_on_goal, :on_target, :off_target, :blocked,
                  :corners, :offsides, :ball_possession, :pass_accuracy, :num_passes,
                  :passes_completed, :distance_covered, :tackles,
                  :clearances, :yellow_cards, :red_cards, :fouls_committed)
      else
        []
      end
    end
  end
  json.last_checked_at match.last_checked_at&.utc&.iso8601
  json.last_changed_at match.last_changed_at&.utc&.iso8601
end
