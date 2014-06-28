require 'open-uri'

namespace :fifa do
  desc "scrape results from FIFA site"
  task get_all_matches: :environment do

    FIFA_SITE = "http://www.fifa.com/"
    MATCH_URL = FIFA_SITE + "worldcup/matches/index.html"
    MAIN_TZ = TZInfo::Timezone.get('America/Sao_Paulo')
    ALT_TZ = TZInfo::Timezone.get('America/Manaus')
    ALT_TIMEZONE_LOCATION = ['Arena Amazonia', 'Arena Pantanal']
    matches = Nokogiri::HTML(open(MATCH_URL))
    counter = 0

    matches.css(".col-xs-12 .mu").each do |match|
      fifa_id = match.first[1] #get unique fifa_id
      match_number = match.css(".mu-i-matchnum").text.gsub("Match ","")
      datetime = match.css(".mu-i-datetime").text
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
        penalty_array = match.css(".mu-reasonwin-abbr").text.split("-")
        home_team_penalties = penalty_array[0].gsub(/[^\d]/, "").to_i
        away_team_penalties = penalty_array[1].gsub(/[^\d]/, "").to_i
      end
      # save match status to use to display live matches via JSON
      if match.css(".s-status").text.downcase.include?("full")
        status = "completed"
      elsif match.attributes["class"].value.include?("live")
        status = "in progress"
      else
        status = "future"
      end
      Time.zone = (ALT_TIMEZONE_LOCATION.include?(location) ? ALT_TZ : MAIN_TZ)
      fixture = Match.find_or_create_by_fifa_id(fifa_id)
      fixture.match_number = match_number
      fixture.datetime = Time.zone.parse(datetime)
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
    puts "checked matches, retrieved #{counter} matches"
  end
end

