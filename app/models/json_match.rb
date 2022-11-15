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
    @info = JSON.parse(json)
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

  def officials
    refs = match_info_officials&.map { |official| official['NameShort'] }&.flatten
    return [] unless refs.is_a? Array

    refs.map { |name| name['Description'] }&.flatten
  end

  def score_info
    {
      home_score: home_team_score,
      away_score: away_team_score,
      home_penalties: home_team_penalty_score,
      away_penalties: away_team_penalty_score
    }
  end

  def home_team_info
    { tactics: home_team['Tactics'],
      starting_eleven: starters,
      substitutes: substitutes,
      coaches: coach_names }
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

  def starters(home: true, away: false)
    home = false if away
    starters = home ? home_team['Players'] : away_team['Players']
    starters = starters.select { |p| p['Status'] == 1 }
    PlayersFormatter.players_from_array(starters)
  end

  def substitutes(home: true, away: false)
    home = false if away
    subs = home ? home_team['Players'] : away_team['Players']
    subs = subs.select { |p| p['Status'] == 2 }
    PlayersFormatter.players_from_array(subs)
  end

  class PlayersFormatter
    class << self
      def players_from_array(players_array)
        create_players_from_match_info(players_array)
      end

      def player_from_hash(player_hash)
        create_player_from_info_hash(player_hash)
      end

      def create_players_from_match_info(array)
        return [] unless array.is_a? Array

        array.map { |player| create_player_from_info_hash(player) }
      end

      def create_player_from_info_hash(player)
        name = player&.dig('PlayerName')&.first&.dig('Description')
        captain = player&.dig('Captain')
        shirt_number = player&.dig('ShirtNumber')
        position = get_position_from(player&.dig('Position'))
        { name:, captain:, shirt_number:, position: }
      end

      def get_position_from(position)
        return nil unless position

        return 'Goalkeeper' if position.to_i.zero?
        return 'Defender' if position.to_i == 1
        return 'Midfielder' if position.to_i == 2
        return 'Forward' if position.to_i == 3

        'Unknown'
      end
    end
  end
end
