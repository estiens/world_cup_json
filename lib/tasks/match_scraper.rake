require 'open-uri'

namespace :fifa do
  desc "scrape results from FIFA site"
  task get_all_matches: :environment do

    FIFA_SITE = "https://www.fifa.com/"
    MATCH_URL = FIFA_SITE + "worldcup/matches/index.html"
    matches = Nokogiri::HTML(open(MATCH_URL))
    counter = 0
    timezone_file = File.read(Rails.root + "lib/assets/timezones.json")

    @timezones = JSON.parse(timezone_file)
    @counter = 0
    @live_counter = 0

    def parse_match(match)
      fifa_id = match.first[1] #get unique fifa_id
      datetime = match.css('.fi-mu__info__datetime')&.text&.strip
      datetime = datetime&.downcase&.gsub('local time', '')&.strip&.to_time
      venue = match.css('.fi__info__venue')&.text
      # comment next line out for set up and scraping of all matches
      # reduces overhead on heroku to only scrape current/future matches
      # next unless datetime&.to_time&.beginning_of_day >= Time.now.beginning_of_day
      location = match.css(".fi__info__stadium").text
      home_team_code = match.css(".home .fi-t__nTri").text
      away_team_code = match.css(".away .fi-t__nTri").text

      # if match is scheduled, associate it with a team, else use tbd variables
      if Team.where(fifa_code: home_team_code).first
        home_team_id = Team.where(fifa_code: home_team_code).first.id
      else
        home_team_tbd = home_team_code
      end
      if Team.where(fifa_code: away_team_code).first
        away_team_id = Team.where(fifa_code: away_team_code).first.id
      else
        away_team_tbd = away_team_code
      end
      # FIFA uses the score class to show the time if the match is in the future
      # We don't want that
      if match.css('.fi-s__scoreText').text.include?("-")
        score_array = match.css('.fi-s__scoreText').text.split("-")
        home_team_score = score_array.first.to_i
        away_team_score = score_array.last.to_i
      else
        home_team_score = away_team_score = 0
      end
      # this is handled by JS hide/show now will have to figure out how to handle
      penalties = match.css(".fi-mu__reasonwin-text").xpath("//wherever/*[not (@class='hidden')]")
      if penalties.text.downcase.include?("win on penalties")
        # not sure is right in 2018
        penalty_array = penalties.text.split("-")
        home_team_penalties = penalty_array[0].gsub(/[^\d]/, "").to_i
        away_team_penalties = penalty_array[1].gsub(/[^\d]/, "").to_i
      end
      # save match status to use to display live matches via JSON

      status = match.css('.fi-s__status').xpath("//wherever/*[not (@class='hidden')]")
      if status.text.downcase.include?('full')
        status = 'completed'
      elsif match.attributes['class'].value.include?('live')
        status = 'in progress'
      else
        status = 'future'
      end
      Time.zone = TZInfo::Timezone.get(@timezones[location])
      fixture = Match.find_or_create_by(fifa_id: fifa_id)
      fixture.venue ||= venue
      fixture.datetime ||= Time.parse(datetime.to_s).localtime
      fixture.location ||= location
      fixture.home_team_id ||= home_team_id
      fixture.away_team_id ||= away_team_id
      fixture.home_team_tbd ||= home_team_tbd
      fixture.away_team_tbd ||= away_team_tbd
      fixture.home_team_score = home_team_score
      fixture.away_team_score = away_team_score
      if home_team_penalties && away_team_penalties
        fixture.home_team_penalties = home_team_penalties
        fixture.away_team_penalties = away_team_penalties
      end
      fixture.status = status
      fixture.save
    end

    matches.css(".fixture").each do |match|
      parse_match(match)
      @counter += 1
    end

    matches.css(".live").each do |match|
      parse_match(match)
      @live_counter += 1
    end

    puts "checked matches, saved #{@counter} matches"
    puts "checked matches, saved #{@live_counter} live matches"
  end
end
