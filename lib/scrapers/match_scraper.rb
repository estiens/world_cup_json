# frozen_string_literal: true

module Scrapers
  # scrapes all matches to set up times and check for live games
  class MatchScraper < BaseScraper
    def initialize
      @url = scraper_url
      super(url: scraper_url)
      @matches = nil
    end

    def verify_past_scores
      @matches = @page.css('.result')
      check_scores_for_matches
    end

    def overwrite_existing_matches
      @page = Nokogiri::HTML(browser.html)
      @matches = page.search('.fixture')
      @matches.each { |m| write_match_data_for_match(m) }
      @results = page.search('.result')
      @matches.each { |m| write_match_data_for_match(m) }
    end

    private

    def scraper_url
      'https://www.fifa.com/worldcup/matches/'
    end

    def write_match_data_for_match(match)
      fifa_id = match.first[1]
      fixture = Match.find_or_create_by(fifa_id: fifa_id)
      scraper_match = Scrapers::ScraperMatch.new(match)
      fixture.datetime = scraper_match.datetime
      fixture.location = scraper_match.location
      fixture.venue = scraper_match.venue
      fixture.status = scraper_match.match_status
      set_fixture_home_team(fixture, scraper_match)
      set_fixture_away_team(fixture, scraper_match)
      determine_status(fixture, scraper_match)
      save_fixture(fixture, scraper_match)
    end

    def save_fixture(fixture, scraper_match)
      if fixture.save
        puts "SAVED #{fixture.name}"
        puts fixture.to_json.to_s
      else
        puts 'Something went wrong'
        puts fixture.errors.full_messages.to_s
      end
    end

    def set_fixture_home_team(fixture, scraper_match)
      home_code = scraper_match.home_team_code
      if Team.where(fifa_code: home_code).first
        fixture.home_team = Team.where(fifa_code: home_code).first
      else
        fixture.home_team_tbd = home_code
      end
    end

    def set_fixture_away_team(fixture, scraper_match)
      away_code = scraper_match.away_team_code
      if Team.where(fifa_code: away_code).first
        fixture.away_team = Team.where(fifa_code: away_code).first
      else
        fixture.away_team_tbd = away_code
      end
    end

    def determine_status(fixture, scraper_match)
      fixture.status = scraper_match.match_status
      return unless fixture.status == 'undetermined'
      fixture.status = if fixture.datetime.to_i > Time.now.to_i
                         'future'
                       else
                         'pending correction'
                       end
    end

    def check_scores_for_matches
      @matches.each do |match|
        fifa_id = match.first[1]
        fixture = Match.find_by(fifa_id: fifa_id)
        unless fixture
          puts "Could not find match for #{fifa_id}"
          next
        end
        scraped_scores = get_scores_for_match(match)
        unless scraped_scores.length == 2
          puts "Could not scrape scores for #{fixture.name}"
          next
        end
        next if verify_scores(scraped_scores, fixture)
      end
      puts 'All Done!'
    end

    def verify_scores(scraped_scores, fixture)
      if scores_match(scraped_scores, fixture)
        puts "verified: #{fixture.name}"
        true
      else
        fixture.status = 'pending_correction'
        fixture.save
        puts "Incorrect Score for #{fixture.name}:
           Scraped Score is #{scraped_scores[0]} - #{scraped_scores[1]}
           and database score is #{fixture.home_team_score} - #{fixture.away_team_score}"
        false
      end
    end

    def scores_match(scraped_score, fixture)
      home = (scraped_score.first == fixture.home_team_score)
      away = (scraped_score.last == fixture.away_team_score)
      home && away
    end

    def get_scores_for_match(match)
      scores = match.search('.fi-s__scoreText')
      return nil unless scores&.text&.include?('-')
      scores&.text&.split('-')&.map(&:to_i)
    end
  end
end

#   desc "scrape results from FIFA site"
#   task get_all_matches: :environment do
#     def parse_match(match)
#       fifa_id = match.first[1] # get unique fifa_id
#       fixture = Match.find_or_create_by(fifa_id: fifa_id)
#       return nil if fixture.status == 'completed'
#
#       datetime = match.css('.fi-mu__info__datetime')&.text&.strip
#       datetime = datetime&.downcase&.gsub('local time', '')&.strip&.to_time
#
#       venue = match.css('.fi__info__venue')&.text
#
#       # comment next line out for set up and scraping of all matches
#       # reduces overhead on heroku to only scrape today's matches
#
#       return nil unless datetime&.beginning_of_day&.to_i == Time.now.beginning_of_day.to_i
#
#       location = match.css(".fi__info__stadium")&.text
#
#       home_team_code = match.css(".home .fi-t__nTri")&.text
#       away_team_code = match.css(".away .fi-t__nTri")&.text
#
#       # if match is scheduled, associate it with a team, else use tbd variables
#       if Team.where(fifa_code: home_team_code).first
#         home_team_id = Team.where(fifa_code: home_team_code).first.id
#       else
#         home_team_tbd = home_team_code
#       end
#       if Team.where(fifa_code: away_team_code).first
#         away_team_id = Team.where(fifa_code: away_team_code).first.id
#       else
#         away_team_tbd = away_team_code
#       end
#
#       fixture.home_team_score ||= 0
#       fixture.away_team_score ||= 0
#       # FIFA uses the score class to show the time if the match is in the future
#       # We don't want that
#       if match.css('.fi-s__scoreText')&.text&.include?("-")
#         score_array = match.css('.fi-s__scoreText').text.split("-")
#         new_ht_score = score_array.first.to_i
#         new_at_score = score_array.last.to_i
#         fixture.home_team_score = new_ht_score if new_ht_score > fixture.home_team_score
#         fixture.away_team_score = new_at_score if new_at_score > fixture.away_team_score
#       end
#       # this is handled by JS hide/show now will have to figure out how to handle
#       penalties = match.css(".fi-mu__reasonwin-text").xpath("//wherever/*[not (@class='hidden')]")
#       if penalties.text.downcase.include?("win on penalties")
#         # not sure is right in 2018
#         penalty_array = penalties.text.split("-")
#         home_team_penalties = penalty_array[0].gsub(/[^\d]/, "").to_i
#         away_team_penalties = penalty_array[1].gsub(/[^\d]/, "").to_i
#       end
#       fixture.venue ||= venue
#       fixture.location ||= location
#       fixture.datetime ||= datetime
#       fixture.home_team_id = home_team_id
#       fixture.away_team_id = away_team_id
#       fixture.home_team_tbd = home_team_tbd
#       fixture.away_team_tbd = away_team_tbd
#       if home_team_penalties && away_team_penalties
#         fixture.home_team_penalties = home_team_penalties
#         fixture.away_team_penalties = away_team_penalties
#       end
#
#       if match.attributes['class'].value.include?('live')
#         fixture.status = 'in progress'
#       elsif match.css('.period').css(":not(.hidden)").text.downcase.include?('full-time')
#         fixture.status = 'end of time'
#       else
#         fixture.status ||= 'future'
#       end
#       fixture.last_score_update_at = Time.now
#       @counter += 1 if fixture.save
#     end
#
#     matches = get_page_from_url(MATCH_URL)
#     @counter = 0
#     @live_counter = 0
#
#     matches.css(".fixture").each do |match|
#       parse_match(match)
#     end
#
#     matches.css(".live").each do |match|
#       parse_match(match)
#       @live_counter += 1
#     end
#
#     puts "checked matches, saved #{@counter} matches"
#     puts "checked matches, saved #{@live_counter} live matches"
#   end
# end
