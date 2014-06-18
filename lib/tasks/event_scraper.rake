require 'open-uri'

namespace :fifa do
  desc "scrape events from FIFA site"
  task get_all_events: :environment do
    FIFA_SITE = "http://www.fifa.com/"
    MATCH_URL = FIFA_SITE + "worldcup/matches/index.html"
    matches = Nokogiri::HTML(open(MATCH_URL))

    matches.css(".col-xs-12 .mu").each do |match|
      fifa_id = match.first[1] #get unique fifa_id

      #get game events
      url = match.children[0]['href']
      next if url == nil
      match_info_page = Nokogiri::HTML(open(FIFA_SITE+url))
      home_events =  []
      away_events = []
      match_info_page.css("td.home").css(".event").each do |event|
        event_type = event.attributes["class"].value.gsub("event ","")
        player = event.parent.parent.parent.css('.p-n').text.titlecase
        home_events << [player, event_type]
      end
      match_info_page.css("td.away").css(".event").each do |event|
        event_type = event.attributes["class"].value.gsub("event ","")
        player = event.parent.parent.parent.css('.p-n').text.titlecase
        away_events << [player, event_type]
      end
      binding.pry
      fixture = Match.find_or_create_by_fifa_id(fifa_id)
      fixture.save
    end
  end
end