require 'open-uri'

namespace :fifa do
  desc "scrape results from FIFA site"
  task get_all_matches: :environment do

    FIFA_SITE = "http://www.fifa.com/"
    MATCH_URL = FIFA_SITE + "womensworldcup/matches/index.html"
    matches = Nokogiri::HTML(open(MATCH_URL))
    counter = 0
    timezone_file = File.read(Rails.root + "lib/assets/timezones.json")
    timezones = JSON.parse(timezone_file)

    matches.css(".col-xs-12 .mu").each do |match|
      fifa_id = match.first[1] #get unique fifa_id
      match_number = match.css(".mu-i-matchnum").text.gsub("Match ","")
      datetime = match.css(".mu-i-datetime").text
      # comment next line out for set up and scraping of all matches
      # reduces overhead on heroku to only scrape current/future matches
      # next unless datetime.to_time.beginning_of_day >= Time.now.beginning_of_day
      location = match.css(".mu-i-stadium").text
      home_team_code = match.css(".home .t-nTri").text
      away_team_code = match.css(".away .t-nTri").text
      #if match is schedule, associate it with a team, else use tbd variables
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
      if match.css(".s-scoreText").text.include?("-")
        score_array= match.css(".s-scoreText").text.split("-")
        home_team_score = score_array.first
        away_team_score = score_array.last
      else
        home_team_score = away_team_score = "0"
      end
      unless match.css(".mu-reasonwin-abbr").text.strip.empty?
        #occasionally appends non penalty shootout messages in this spot
        if match.css(".mu-reasonwin-abbr").text.downcase.include?("pso")
          penalty_array = match.css(".mu-reasonwin-abbr").text.split("-")
          home_team_penalties = penalty_array[0].gsub(/[^\d]/, "").to_i
          away_team_penalties = penalty_array[1].gsub(/[^\d]/, "").to_i
        end
      end
      # save match status to use to display live matches via JSON
      if match.css(".s-status").text.downcase.include?("full")
        status = "completed"
      elsif match.attributes["class"].value.include?("live")
        status = "in progress"
      else
        status = "future"
      end
      Time.zone = TZInfo::Timezone.get(timezones[location])
      fixture = Match.find_or_create_by_fifa_id(fifa_id)
      fixture.match_number = match_number
      fixture.datetime = Time.parse(datetime).localtime
      fixture.location = location
      fixture.home_team_id = home_team_id
      fixture.away_team_id = away_team_id
      fixture.home_team_tbd = home_team_tbd
      fixture.away_team_tbd = away_team_tbd
      fixture.home_team_score = home_team_score
      fixture.away_team_score = away_team_score
      if home_team_penalties && away_team_penalties
        fixture.home_team_penalties = home_team_penalties
        fixture.away_team_penalties = away_team_penalties
      end
      fixture.status = status
      fixture.save
      counter += 1
    end
    puts "checked matches, saved #{counter} matches"
  end
end