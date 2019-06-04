module Scrapers
  class JsonScraper
    include HTTParty

    def self.write_fifa_info
      base_url = get_base_url
      response = get(base_url)
      json = JSON.parse(response.body)
      Match.all.each do |fixture|
        match_info = json['Results'].find { |match| match['IdMatch'] == fixture.fifa_id }
        json_match = Scrapers::JsonMatch.new(match_info)
        write_fifa_info_for_match(fixture, json_match)
      end
    end

    def self.get_base_url
      browser = ChromeBrowserHelper.browser
      browser.goto('https://www.fifa.com/womensworldcup/')
      html = Nokogiri::HTML(browser.html)
      url = html.search('script')&.text&.match(/matchListUpdate.url(.+)/)[0]&.match(/https:\/\/(.+);_cfg/)[1]&.to_s
      return "https://#{url}&count=500" if url
      "https://api.fifa.com/api/v1/live/football/recent/103/278513?idClient=64e9afa8-c5c0-413d-882b-bc9e6a81e264&language=en-GB&count=500"
    end

    def self.write_fifa_info_for_match(fixture, json_match)
      fixture.fifa_competition_id ||= json_match.fifa_competition_id
      fixture.fifa_season_id ||= json_match.fifa_season_id
      fixture.fifa_group_id ||= json_match.fifa_group_id
      fixture.fifa_stage_id ||= json_match.fifa_stage_id
      fixture.stage_name ||= json_match.stage_name
      fixture.save
    end

    def self.write_all_info_for_match(fifa_id)
      match = Match.find_by(fifa_id: fifa_id)
      unless match
        puts 'No match with that id'
        return
      end
      me = new(match)
      if me.grab_match_info
        puts "Wrote Stats from JSON for #{match.name}"
      else
        puts "Couldn't write JSON for #{match.name}"
      end
    end

    def initialize(fixture)
      @fixture = fixture
    end

    def grab_match_info
      response = self.class.get(match_url)
      if response.code == 200
        match_info = JSON.parse(response.body)
        return false if match_info.blank?
        json_match = Scrapers::JsonMatch.new(match_info)
        write_match_info(json_match)
        write_scores(json_match)
        write_match_stats(json_match)
        return @fixture.save
      end
      false
    end

    private

    def write_match_info(json_match)
      @fixture.attendance = json_match.attendance
      @fixture.weather = json_match.weather_info
      @fixture.officials = json_match.officials
    end

    def write_scores(json_match)
      @fixture.json_home_team_score = json_match.home_score
      @fixture.json_away_team_score = json_match.away_score
      @fixture.json_away_team_penalties = json_match.away_penalties
      @fixture.json_home_team_penalties = json_match.home_penalties
    end

    def write_match_stats(json_match)
      home_stats = MatchStatistic.find_or_create_by(match: @fixture, team: @fixture.home_team)
      away_stats = MatchStatistic.find_or_create_by(match: @fixture, team: @fixture.away_team)
      home_stats.tactics = json_match.home_team_tactics
      away_stats.tactics = json_match.away_team_tactics
      home_stats.starting_eleven = json_match.home_starting_eleven
      away_stats.starting_eleven = json_match.away_starting_eleven
      home_stats.substitutes = json_match.home_team_substitutes
      away_stats.substitutes = json_match.away_team_substitutes
      home_stats.save && away_stats.save
    end

    def match_url
      base_url = 'https://api.fifa.com/api/v1/live/football'
      base_url += "/#{@fixture.fifa_competition_id}"
      base_url += "/#{@fixture.fifa_season_id}"
      base_url += "/#{@fixture.fifa_stage_id}"
      base_url += "/#{@fixture.fifa_id}"
    end
  end
end
