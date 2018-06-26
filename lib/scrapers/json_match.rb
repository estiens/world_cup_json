module Scrapers
  class JsonMatch

    attr_reader :match_info

    def initialize(match_info_json)
      @match_info = match_info_json
    end

    def fifa_competition_id
      @fifa_competition_id ||= @match_info.dig('IdCompetition')
    end

    def fifa_season_id
      @fifa_season_id ||= @match_info.dig('IdSeason')
    end

    def fifa_stage_id
      @fifa_stage_id ||= @match_info.dig('IdStage')
    end

    def fifa_group_id
      @fifa_group_id ||= @match_info.dig('IdGroup')
    end

    def weather_info
      return @weather_info if @weather_info
      @weather_info = { humidity: humidity, temp_celsius: temp_celsius,
                        temp_farenheit: temp_farenheit, wind_speed: wind_speed,
                        description: weather_description }
    end

    def weather
      @weather ||= @match_info.dig('Weather')
    end

    def attendance
      @attendance ||= @match_info.dig("Attendance")
    end

    def humidity
      @humidity ||= weather.dig('Humidity')
    end

    def temp_celsius
      @temp_celsius ||= weather.dig('Temperature')
    end

    def temp_farenheit
      return nil unless temp_celsius
      return @temp_farenheit if @temp_farenheit
      faren = (temp_celsius.to_i * (9/5) + 32)
      @temp_farenheit = faren.to_s
    end

    def wind_speed
      @wind_speed ||= weather.dig('WindSpeed')
    end

    def weather_description
      @weather_description ||= weather.dig('TypeLocalized')&.first&.dig('Description')
    end

    def stage_name
      return @stage_name if @stage_name
      name = @match_info.dig('StageName')
      return unless name
      @stage_name = name.find { |stage| stage['Locale'] == 'en-GB' }&.dig('Description')
    end

    def home_team_tactics
      @home_team_tactics ||= @match_info.dig('HomeTeam','Tactics')
    end

    def away_team_tactics
      @away_team_tactics ||= @match_info.dig('AwayTeam','Tactics')
    end

    def home_score
      @home_team_score ||= @match_info.dig('HomeTeamScore')
      @home_team_score ||=  @match_info.dig('HomeTeam', 'Score')
    end

    def away_score
      @away_team_score ||= @match_info.dig('AwayTeamScore')
      @away_team_score ||=  @match_info.dig('AwayTeam', 'Score')
    end

    def home_penalties
      @home_penalties = @match_info.dig('HomeTeamPenaltyScore')
    end

    def away_penalties
      @away_penalties = @match_info.dig('AwayTeamPenaltyScore')
    end

    def home_starting_eleven
      return @home_starting_eleven if @home_starting_eleven
      players = @match_info&.dig('HomeTeam')&.dig('Players')&.find_all { |player| player['Status'] == 1 }
      @home_starting_eleven = create_players_from_match_info(players)
    end

    def away_starting_eleven
      return @away_starting_eleven if @away_starting_eleven
      players = @match_info&.dig('AwayTeam')&.dig('Players')&.find_all { |player| player['Status'] == 1 }
      @away_starting_eleven = create_players_from_match_info(players)
    end

    def home_team_substitutes
      return @home_team_substitutes if @home_team_substitutes
      players = @match_info&.dig('HomeTeam')&.dig('Players')&.find_all { |player| player['Status'] == 2 }
      @home_team_substitutes = create_players_from_match_info(players)
    end

    def away_team_substitutes
      return @away_team_substitutes if @away_team_substitutes
      players = @match_info&.dig('AwayTeam')&.dig('Players')&.find_all { |player| player['Status'] == 2 }
      @away_team_substitutes = create_players_from_match_info(players)
    end

    def officials
      return @officials if @officials
      refs = @match_info['Officials']&.map { |off| off['NameShort'] }
      names = refs&.flatten&.map { |name| name["Description"] }&.flatten
      @officals = names
    end

    private

    def create_players_from_match_info(array)
      player_array = []
      array.each do |player|
        name = player&.dig('PlayerName')&.first&.dig('Description')
        captain = player&.dig('Captain')
        shirt_number = player&.dig('ShirtNumber')
        position = get_position_from(player&.dig('Position'))
        player_array << { name: name, captain: captain, shirt_number: shirt_number, position: position }
      end
      player_array
    end

    def get_position_from(position)
      case position
      when 0
        'Goalie'
      when 1
        'Defender'
      when 2
        'Midfield'
      when 3
        'Forward'
      else
        'Unknown'
      end
    end
  end
end
