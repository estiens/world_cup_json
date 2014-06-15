require 'open-uri'

namespace :fifa do
  desc "scrape results from FIFA site"
  task get_all_matches: :environment do
    FIFA_SITE = "http://www.fifa.com/"
    MATCH_URL = FIFA_SITE + "worldcup/matches/index.html"
    matches = Nokogiri::HTML(open(MATCH_URL))

    matches.css(".col-xs-12 .mu").each do |match|
      fifa_id = match.first[1]
      match_number = match.css(".mu-i-matchnum").text.gsub("Match ","")
      datetime = match.css(".mu-i-datetime").text.to_time
      location = match.css(".mu-i-stadium").text
      home_team_code = match.css(".home .t-nTri").text
      away_team_code = match.css(".away .t-nTri").text
      if Team.where(fifa_code: home_team_code).first
        home_team_id = Team.where(fifa_code: home_team_code).first.id
        away_team_id = Team.where(fifa_code: away_team_code).first.id
        teams_scheduled = true
      else
        teams_scheduled = false
        home_team_tbd = home_team_code
        away_team_tbd = away_team_code
      end
      if match.css(".s-scoreText").text.include?("-")
        score_array= match.css(".s-scoreText").text.split("-")
        home_team_score = score_array.first
        away_team_score = score_array.last
      else
        home_team_score = away_team_score = "0"
      end
      if match.css(".s-status").text.downcase.include?("full")
        status = "completed"
      elsif match.attributes["class"].value.include?("live")
        status = "in progress"
      else
        status = "future"
      end
      fixture = Match.find_or_create_by_fifa_id(fifa_id)
      fixture.match_number = match_number
      fixture.datetime = datetime
      fixture.location = location
      fixture.home_team_id = home_team_id
      fixture.away_team_id = away_team_id
      fixture.home_team_tbd = home_team_tbd
      fixture.away_team_tbd = away_team_tbd
      fixture.teams_scheduled = teams_scheduled
      fixture.home_team_score = home_team_score
      fixture.away_team_score = away_team_score
      fixture.status = status
      fixture.save
    end
  end
end

