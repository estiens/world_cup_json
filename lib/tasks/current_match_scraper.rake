require 'open-uri'

namespace :fifa do
  desc "scrape results from FIFA site"
  task get_all_matches: :environment do
    FIFA_SITE = "http://www.fifa.com/"
    MATCH_URL = FIFA_SITE + "worldcup/matches/index.html"

    matches = Nokogiri::HTML(open(MATCH_URL))

    matches.css(".col-xs-12").each do |match|
      match_link = match.at_css("a.mu-m-link")
      next unless match_link
      match_url = FIFA_SITE + match_link["href"]
      home_team_code = match.css(".home .t-nTri").text
      home_team = Team.where(fifa_code: home_team_code).first || "home_team_code"
      away_team_code = match.css(".away .t-nTri").text
      away_team = Team.where(fifa_code: away_team_code).first || "away_team_code"

      match_page = Nokogiri::HTML(open(match_url))

      score_array = match_page.css(".s-scoreText").text[-3..-1].split("-").map(&:to_i)
      home_score = score_array.first
      away_score = score_array.last
      game_time = match_page.at(".lb-post .event-minute").try(:text)

      if game_time
        unless game_time.include?("90'+")
          status = "current"
        else
          status = "finished"
        end
      else
        status = "future"
      end

      puts "#{home_team.country}: #{home_score} -- #{away_team.country} #{away_score} : #{status}"
    end
  end
end






