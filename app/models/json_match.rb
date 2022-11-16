#    Winner -- check how reported
#    ResultType -- check mapping
#    OfficialityStatus -- check mapping
#    IsUpdateable -- can determine if currently live?

class JsonMatch
  attr_reader :info

  # identifiers, date_info, location_info, general_info
  # home_team_info, away_team_info, score_info, current_time_info
  # home_team, away_team

  def initialize(json)
    @info = json if json.is_a? Hash
    @info ||= JSON.parse(json)
  end

  def to_s
    @info.to_json
  end

  # if we call #match_date, it will check @match_info['Date']
  # if we call #match_stage_name, it will check @match_info['StageName']
  def method_missing(method, *_args)
    if method =~ /match_(.*)/
      hash_key = Regexp.last_match(1).to_s.titlecase.gsub(' ', '')
      @info[hash_key]
    else
      super
    end
  end

  def identifiers
    { fifa_id: match_id_match, season_id: match_id_season,
      stage_id: match_id_stage, group_id: match_id_group,
      competition_id: match_id_competition,
      stage_name: stage_name }
  end

  def stage_name
    return nil unless match_stage_name.is_a? Array
    return nil unless match_stage_name.first.is_a? Hash

    match_stage_name.first['Description']
  end

  def date_info
    { date: match_date, local_date: match_local_date }
  end

  def placeholder_teams
    { home_team: match_place_holder_a, away_team: match_place_holder_b }
  end

  def away_team
    @away_team ||= begin
      info = match_away_team.is_a?(Hash) ? match_away_team : match_away
      info.is_a?(Hash) ? info : {}
    end
  end

  def home_team
    @home_team ||= begin
      info = match_home_team.is_a?(Hash) ? match_home_team : match_home
      info.is_a?(Hash) ? info : {}
    end
  end

  def home_team_id
    Team.find_by(fifa_code: home_team['IdTeam'])&.id
  end

  def away_team_id
    Team.find_by(fifa_code: away_team['IdTeam'])&.id
  end

  def current_time_info
    @current_time_info ||=
      {
        current_time: match_match_time,
        first_half_time: match_first_half_time, first_half_extra_time: match_first_half_extra_time,
        second_half_time: match_second_half_time, second_half_extra_time: match_second_half_extra_time
      }
  end

  def location_info
    { venue: match_venue, location: match_location }
  end

  # location info
  def match_location
    match_stadium['CityName']&.first&.dig('Description')
  end

  def match_venue
    match_stadium['Name']&.first&.dig('Description')
  end

  def general_info
    {
      attendance: match_attendance.blank? ? nil : match_attendance,
      weather: weather_info,
      officials: officials
    }
  end

  def weather_info
    return @weather_info if @weather_info
    return {} unless match_weather.is_a? Hash

    @weather_info = { humidity: match_weather['Humidity'],
                      temp_celsius: match_weather['Temperature'],
                      temp_farenheit: convert_to_f(match_weather['Temperature']),
                      wind_speed: match_weather['WindSpeed'],
                      description: match_weather['TypeLocalized']&.first&.dig('Description') }
  end

  def convert_to_f(degrees_c)
    return nil unless degrees_c

    (degrees_c.to_i * (9 / 5) + 32).to_s
  end

  def map_official(official)
    { name: official['NameShort']&.first&.fetch('Description'),
      role: official['TypeLocalized']&.first&.fetch('Description'),
      country: official['IdCountry'] }
  end

  def officials
    @officials ||= info['Officials']&.map { |official| map_official(official) }
  end

  # double check logic on these
  def in_progress?
    return true if current_time_info[:current_time].to_i.positive?
    return true if match_officiality_status.positive?

    false
  end

  def completed?
    return true if match_property_period.to_i == 10 && match_officiality_status.to_i == 2

    false
  end

  def score_info
    {
      home_score: home_team['Score'],
      away_score: away_team['Score'],
      home_penalties: match_home_team_penalty_score,
      away_penalties: match_away_team_penalty_score
    }
  end

  def home_team_info
    { tactics: home_team['Tactics'],
      starting_eleven: starters,
      substitutes: substitutes,
      coaches: coach_names }
  end

  def home_team_events
    { goals: home_team['Goals'], bookings: home_team['Bookings'], substitutions: home_team['Substitutions'] }
  end

  def away_team_events
    { goals: away_team['Goals'], bookings: away_team['Bookings'], substitutions: away_team['Substitutions'] }
  end

  def away_team_info
    { tactics: away_team['Tactics'],
      starting_eleven: starters(away: true),
      substitutes: substitutes(away: true),
      coaches: coach_names(away: true) }
  end

  def coach_names(home: true, away: false)
    home = false if away
    coaches = home ? home_team['Coaches'] : away_team['Coaches']
    coaches.map { |c| c['Name'].map { |d| d['Description'] } }&.flatten
  end

  def find_player_by_id(id)
    find_home_team_player(id).presence || find_away_team_player(id)
  end

  def find_home_team_player(player_id)
    @home_players ||= home_team_info[:starting_eleven] + home_team_info[:substitutes]
    @home_players&.find { |p| p[:fifa_id] == player_id }&.fetch(:name)&.titlecase
  end

  def find_away_team_player(player_id)
    @away_players ||= away_team_info[:starting_eleven] + away_team_info[:substitutes]
    @away_players&.find { |p| p[:fifa_id] == player_id }&.fetch(:name)&.titlecase
  end

  def starters(home: true, away: false)
    home = false if away
    starters = home ? home_team['Players'] : away_team['Players']
    return nil if starters.blank?

    starters = starters.select { |p| p['Status'] == 1 }
    PlayersFormatter.players_from_array(starters)
  end

  def substitutes(home: true, away: false)
    home = false if away
    subs = home ? home_team['Players'] : away_team['Players']
    return nil if subs.blank?

    subs = subs.select { |p| p['Status'] == 2 }
    PlayersFormatter.players_from_array(subs)
  end
end
