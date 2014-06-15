require 'open-uri'

namespace :fifa do
  desc "scrape results from FIFA site"
  task get_all_matches: :environment do
    FIFA_SITE = "http://www.fifa.com/"
    MATCH_URL = FIFA_SITE + "worldcup/matches/index.html"
    matches = Nokogiri::HTML(open(MATCH_URL))

    matches.css(".col-xs-12 .mu").each do |match|
      data_id = match.first[1]
      match_number = match.css(".mu-i-matchnum").text.gsub("Match ","")
      date = match.css(".mu-i-datetime").text.to_time
      venue = match.css(".mu-i-stadium").text
      home_team_code = match.css(".home .t-nTri").text
      away_team_code = match.css(".away .t-nTri").text
      if Team.where(fifa_code: home_team_code).first
        home_team = Team.where(fifa_code: home_team_code).first
        away_team = Team.where(fifa_code: away_team_code).first
        teams_scheduled = true
      else
        teams_scheduled = false
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
        status = "not yet completed"
      end
      puts "Data ID: #{data_id}"
      puts "Match #{match_number}: #{date}, #{venue}"
      if teams_scheduled
        puts "#{home_team.country}: #{home_team_score} -- #{away_team.country} #{away_team_score}"
      else
        puts "#{home_team_code} #{home_team_score} -- #{away_team_code} #{away_team_score}"
      end
      puts "Match Status #{status}\n-----"
    end
  end
end



# <div data-id="300186456" class="mu result">
# <a href="/worldcup/matches/round=255931/match=300186456/index.html#nosticky" class="mu-m-link">
# <div class="mu-i">
# <div class="mu-i-datetime">12 Jun 2014 - 17:00 <span class="wrap-localtime">Local time</span></div>
# <div class="mu-i-date">12 Jun 2014</div><div class="mu-i-matchnum">Match 1</div>
# <div class="mu-i-group">Group A</div><div class="mu-i-location">
# <div class="mu-i-stadium">Arena Corinthians</div><div class="mu-i-venue">Sao Paulo </div></div></div>
# <div class="mu-day"><span class="t-day">12</span><span class="t-month">Jun</span></div>
# <div class="mu-m"><div class="t home" data-team-id="43924"><div class="t-i i-4"><span class="t-i-wrap"><img src="http://img.fifa.com/images/flags/4/bra.png" alt="Brazil" class="BRA i-4-flag flag" /></span></div>
# <div class="t-n"><span class="t-nText ">Brazil</span><span class="t-nTri">BRA</span></div></div>
# <div class="t away" data-team-id="43938"><div class="t-i i-4"><span class="t-i-wrap"><img src="http://img.fifa.com/images/flags/4/cro.png" alt="Croatia" class="CRO i-4-flag flag" /></span></div>
# <div class="t-n"><span class="t-nText ">Croatia</span><span class="t-nTri">CRO</span></div></div><div class="s"><div class="s-fixture">
# <div class="s-status">Full-time </div><div class="s-status-abbr">FT </div><div class="s-score s-date-HHmm" data-daymonthutc="1206">
# <span class="s-scoreText">3-1</span>   </div></div></div><div class="mu-reasonwin"><span class="icon-mrep"> </span><span class="icon-hl"> </span> </div><div class="mu-reasonwin-abbr"><span class="icon-mrep"> </span><span class="icon-hl"> </span> </div></div></a></div>






