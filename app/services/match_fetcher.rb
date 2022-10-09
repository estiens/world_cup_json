class MatchFetcher
  SINGLE_MATCH_URL = 'https://api.fifa.com/api/v3/live/football/17/255711/'.freeze
  ALL_MATCH_URL = 'https://api.fifa.com/api/v3/calendar/matches?from=2022-11-19T00%3A00%3A00Z&to=2022-12-31T23%3A59%3A59Z&language=en&count=500&idCompetition=17'.freeze

  def self.all_matches
    response = HTTParty.get(ALL_MATCH_URL)
    return nil unless response.success?

    match_array = JSON.parse(response.body)['Results']
    match_array.is_a?(Array) ? match_array : nil
  end

  def self.json_for_scheduled_match(match)
    url = "#{SINGLE_MATCH_URL}#{match.fifa_stage_id}/#{match.fifa_id}?language=en"
    response = HTTParty.get(url)
    return {} unless response.success?

    json = JSON.parse(response.body)
    json.is_a?(Hash) ? json.to_json : nil
  end

  def self.scrape_for_general_info(matches)
    match_info = all_matches
    matches.map do |match|
      match = match.is_a?(Match) ? match : Match.find(match)
      match_specific_info = match_info.find { |m| m['IdMatch'] == match.fifa_id }
      if match_specific_info
        match.update(latest_json: match_specific_info.to_json)
        match.id
      else
        Rails.logger.info("**SCRAPER** Match #{match.fifa_id} not found in general info")
        match.touch
        nil
      end
    end.compact
  end

  def self.scrape_for_scheduled_match(match)
    json = json_for_scheduled_match(match)
    unless json.present?
      Rails.logger.info("**SCRAPER** Match #{match.fifa_id} specific info not found")
      return false
    end
    match.update(latest_json: json)
  end
end
