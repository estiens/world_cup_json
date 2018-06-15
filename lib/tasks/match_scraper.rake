require 'open-uri'

FIFA_SITE = "https://www.fifa.com/"
MATCH_URL = FIFA_SITE + "worldcup/matches/index.html"
EVENTS_URL = FIFA_SITE + "worldcup/matches/match/"

namespace :fifa do
  desc "scrape results from FIFA site"
  task get_all_matches: :environment do
    def get_page_from_url(url)
      opts = { headless: true }
      if (chrome_bin = ENV.fetch('GOOGLE_CHROME_SHIM', nil))
        opts.merge!( options: { binary: chrome_bin } )
      end
      browser = Watir::Browser.new :chrome, opts
      browser.goto(url)
      Nokogiri::HTML(browser.html)
    end

    def parse_events(match)
      events_url = EVENTS_URL + "#{match.fifa_id}/"
      events = get_page_from_url(events_url)
      time = events.css('.period').css(":not(.hidden)")&.children&.first&.text&.strip&.downcase
      match.time = time
      event_array = []
      event_list = events.search('.fi-p__events .fi-p__events-wrap')
      event_list.each do |event|
        event_type = event.children.css('.fi-p__event')&.first&.attributes['class']&.value&.gsub('fi-p__event','')&.gsub('--','')&.strip
        event_minute = event.children.css('.fi-p__event')&.first&.attributes['title']&.value&.downcase
        event_player = event.parent&.parent&.attributes['data-player-name']&.value
        home = event.parent&.parent&.parent&.attributes['class']&.value&.include?('home')
        event_hash = { type: event_type, player: event_player, time: event_minute, home: home }
        event_array << event_hash
      end
      event_array.each_with_index do |event, idx|
        team_id = event[:home] ? match.home_team_id : match.away_team_id
        attrs = { player: event[:player],
                  team_id: team_id,
                  type_of_event: event[:type],
                  time: event[:time],
                  match_id: match.id
                }
        next if Event.find_by(attrs)
        if event = Event.create(attrs)
          puts "#{attrs} event created"
        else
          puts event.errors
        end
      end
      match.save
      return true if time == 'full-time'
      return false
    end

    def parse_match(match)
      fifa_id = match.first[1] #get unique fifa_id
      fixture = Match.find_or_create_by(fifa_id: fifa_id)
      return nil if fixture.status == 'completed'

      datetime = match.css('.fi-mu__info__datetime')&.text&.strip
      datetime = datetime&.downcase&.gsub('local time', '')&.strip&.to_time
      venue = match.css('.fi__info__venue')&.text
      # comment next line out for set up and scraping of all matches
      # reduces overhead on heroku to only scrape current/future matches

      # return nil unless datetime&.to_time&.beginning_of_day >= Time.now.beginning_of_day
      location = match.css(".fi__info__stadium")&.text
      home_team_code = match.css(".home .fi-t__nTri")&.text
      away_team_code = match.css(".away .fi-t__nTri")&.text

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
      if match.css('.fi-s__scoreText')&.text&.include?("-")
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
      fixture.venue ||= venue
      fixture.location ||= location
      end
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
      if match.attributes['class'].value.include?('live')
        status = 'in progress'
      elsif match.css('.period').css(":not(.hidden)").text.downcase.include?('full-time')
        status = 'end of time'
      else
        status = 'future'
      end

      if status == 'in progress' || status == 'end of time'
        events = parse_events(fixture)
        status = 'completed' if events == true
      end
      fixture.status = status
      @counter += 1 if fixture.save
    end

    matches = get_page_from_url(MATCH_URL)
    timezone_file = File.read(Rails.root + "lib/assets/timezones.json")
    @timezones = JSON.parse(timezone_file)
    @counter = 0
    @live_counter = 0
    @ended_counter = 0

    matches.css(".fixture").each do |match|
      parse_match(match)
    end

    matches.css(".live").each do |match|
      parse_match(match)
      @live_counter += 1
    end

    matches.css(".result").each do |match|
      parse_match(match)
      @ended_counter +=1
    end

    puts "checked matches, saved #{@counter} matches"
    puts "checked matches, saved #{@live_counter} live matches"
    puts "checked matches, saved #{@ended_counter} old matches"
  end
end
