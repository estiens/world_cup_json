class JsonMatch
  class EventWriter
    def initialize(match: nil)
      @match = match
      @json_match = JsonMatch.new(match.latest_json)
    end

    def write!
      try_create_home_events
      try_create_away_events
      write_stats
    end

    def write_stats
      JsonStat.new(match: @match) if @match.home_stats.last_updated < 2.minutes.ago
    rescue StandardError => e
      Rails.logger.info "Error writing stats for match #{@match.id}: #{e.inspect}"
      nil
    end

    private

    def home_events
      @home_events ||= @json_match.home_team_events
    end

    def away_events
      @away_events ||= @json_match.away_team_events
    end

    def players_for_event(event_json)
      player = @json_match.find_player_by_id(event_json['IdPlayer'])
      event_json[:player_name] = player&.titlecase
      event_json[:player_off] = event_json['PlayerOffName']&.first&.[]('Description')&.titlecase
      event_json[:player_on] = event_json['PlayerOnName']&.first&.[]('Description')&.titlecase
      event_json
    end

    def get_position_from(position)
      return nil unless position

      return 'Goalkeeper' if position.to_i.zero?
      return 'Defender' if position.to_i == 1
      return 'Midfielder' if position.to_i == 2
      return 'Forward' if position.to_i == 3

      'Unknown'
    end

    def home_bookings
      home_events[:bookings] || []
    end

    def home_goals
      home_events[:goals] || []
    end

    def home_substitutions
      home_events[:substitutions] || []
    end

    def away_bookings
      away_events[:bookings] || []
    end

    def away_goals
      away_events[:goals] || []
    end

    def away_substitutions
      away_events[:substitutions] || []
    end

    def write_event_json(json:, team_id:, type:)
      json = players_for_event(json)
      json = json.transform_keys { |k| k.to_s.underscore.downcase.to_sym }
      ev = Event.new(match: @match, event_json: json.to_json, team_id: team_id, type_of_event: type)
      ev.save
    end

    def try_create_away_events
      away_goals.each { |goal| write_event_json(json: goal, team_id: @match.away_team&.id, type: 'goal') }
      away_substitutions.each { |sub| write_event_json(json: sub, team_id: @match.away_team&.id, type: 'substitution') }
      away_bookings.each { |book| write_event_json(json: book, team_id: @match.away_team&.id, type: 'booking') }
    end

    def try_create_home_events
      home_goals.each { |goal| write_event_json(json: goal, team_id: @match.home_team&.id, type: 'goal') }
      home_substitutions.each { |sub| write_event_json(json: sub, team_id: @match.home_team&.id, type: 'substitution') }
      home_bookings.each { |book| write_event_json(json: book, team_id: @match.home_team&.id, type: 'booking') }
    end
  end
end
