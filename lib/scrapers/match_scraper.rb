# frozen_string_literal: true

module Scrapers
  # scrapes all matches to set up times and check for live games
  class MatchScraper < BaseScraper
    def initialize(force: false, before_events: false)
      super()
      @url = scraper_url
      @force = force
      @before_events = before_events
      @matches = nil
      @counter = 0
      @page = nil
    end

    def verify_past_scores
      @page = scrape_page_from_url(before_events: false)
      @matches = @page.css('.result')
      check_scores_for_matches
    end

    def write_past_matches
      @page = scrape_page_from_url(before_events: false)
      @matches = page.search('.result')
      @matches.each { |m| write_match_data_for_match(m) }
      puts "#{@counter} matches written"
    end

    def write_future_matches
      @page = scrape_page_from_url(before_events: true)
      @matches = page.search('.fixture')
      @matches.each { |m| write_match_data_for_match(m) }
      puts "#{@counter} matches written"
    end

    def fix_times
      @page = scrape_page_from_url(before_events: true)
      @matches = page.search('.fixture')
      @matches.each { |m| write_time_data_for_match(m) }
      @matches = page.search('.result')
      @matches.each { |m| write_time_data_for_match(m) }
    end

    def check_for_live_status
      unless Match.today.future.count > 0
        puts 'no matches to check for!'
        return
      end
      @page = scrape_page_from_url(before_events: false)
      @matches = page.search('.live')
      @matches.each { |m| write_status_for_match(m) }
      return unless Match.in_progress.count.positive?
      puts "#{Match.in_progress.first.name} in progress"
    end

    private

    def before_scrape_events(execute = false)
      return unless execute
      @browser.link(text: 'Knockout Phase').click!
      @browser.link(text: 'List view').click!
      @browser.execute_script("$('.fi-knockout-tabs #listview').show();")
      Watir::Wait.until { @browser.element(id: 'listview').visible? }
    end

    def scraper_url
      'https://www.fifa.com/worldcup/matches/'
    end

    def write_status_for_match(match)
      fifa_id = match.first[1]
      @fixture = Match.find_or_create_by(fifa_id: fifa_id)
      scraper_match = Scrapers::ScraperMatch.new(match)
      determine_status(scraper_match)
      save_fixture
    end

    def write_time_data_for_match(match)
      fifa_id = match.first[1]
      @fixture = Match.where(fifa_id: fifa_id).first
      return unless @fixture
      scraper_match = Scrapers::ScraperMatch.new(match)
      return unless scraper_match
      unless scraper_match.datetime
        puts 'could not parse time'
        return
      end
      if @fixture.datetime != scraper_match.datetime
        puts "Changing #{@fixture.name} -- #{@fixture.datetime} to #{scraper_match.datetime}"
        @fixture.datetime = scraper_match.datetime
        @fixture.save
      else
        puts "#{@fixture.name} is correct"
      end
    end

    def write_time_date(scraper_match)
      unless scraper_match.datetime
        puts 'could not parse time'
        return
      end
      if @fixture.datetime != scraper_match.datetime
        puts "Changing #{@fixture.name} -- #{@fixture.datetime} to #{scraper_match.datetime}"
        @fixture.datetime = scraper_match.datetime
        @fixture.save
      else
        puts "#{@fixture.name} is correct"
      end
    end

    def write_match_data_for_match(match)
      fifa_id = match.first[1]
      @fixture = Match.find_or_create_by(fifa_id: fifa_id)
      if @fixture.completed? && !@force
        puts "Not checking date for #{@fixture.name}. Completed."
        return
      end
      scraper_match = Scrapers::ScraperMatch.new(match)
      # don't really need to do this unless something weird happens
      write_time_date(scraper_match) if @force
      check_for_new_values(scraper_match) if @force
      @fixture.home_team_score ||= 0
      @fixture.away_team_score ||= 0
      set_fixture_home_team(scraper_match)
      set_fixture_away_team(scraper_match)
      determine_status(scraper_match)
      save_fixture
    end

    def check_for_new_values(scraper_match)
      if scraper_match.datetime && scraper_match.datetime != @fixture.datetime
        @fixture.datetime = scraper_match.datetime
      end
      if scraper_match.venue && scraper_match.venue != @fixture.venue
        @fixture.venue = scraper_match.venue
      end
      if scraper_match.location && scraper_match.location != @fixture.location
        @fixture.location = scraper_match.location
      end
    end

    def save_fixture
      if @fixture.save
        @counter += 1
        puts "SAVED #{@fixture.name}"
      else
        puts "Something went wrong! #{@fixture.errors.full_messages}"
      end
    end

    def set_fixture_home_team(scraper_match)
      home_code = scraper_match.home_team_code
      if Team.where(fifa_code: home_code).first
        @fixture.home_team = Team.where(fifa_code: home_code).first
      else
        @fixture.home_team_tbd = home_code
      end
    end

    def set_fixture_away_team(scraper_match)
      away_code = scraper_match.away_team_code
      if Team.where(fifa_code: away_code).first
        @fixture.away_team = Team.where(fifa_code: away_code).first
      else
        @fixture.away_team_tbd = away_code
      end
    end

    def determine_status(scraper_match)
      @fixture.status = scraper_match.match_status
      return unless @fixture.status == 'undetermined'
      @fixture.status = if @fixture.datetime.to_i > Time.now.to_i
                         'future'
                       else
                         'pending correction'
                       end
    end

    def check_scores_for_matches
      @verify_counter = 0
      @matches.each do |match|
        fifa_id = match.first[1]
        @fixture = Match.find_by(fifa_id: fifa_id)
        unless @fixture
          puts "Could not find match for #{fifa_id}"
          next
        end
        scraped_scores = get_scores_for_match(match)
        unless scraped_scores.length == 2
          puts "Could not scrape scores for #{fixture.name}"
          next
        end
        next if verify_scores(scraped_scores)
      end
      puts "All Done! #{@verify_counter} matches verified of #{@matches.length}"
    end

    def verify_scores(scraped_scores)
      if scores_match(scraped_scores)
        puts "verified: #{@fixture.name}"
        @verify_counter += 1
        true
      else
        @fixture.status = 'pending_correction'
        @fixture.events_complete = false
        puts "Incorrect Score for #{@fixture.name}:
           Scraped Score is #{scraped_scores[0]} - #{scraped_scores[1]}
           and database score is #{@fixture.home_team_score} - #{@fixture.away_team_score}"
        # reset scores for re-scrape
        @fixture.home_team_score = @fixture.away_team_score = 0
        @fixture.save
        false
      end
    end

    def scores_match(scraped_score)
      home = (scraped_score.first == @fixture.home_team_score)
      away = (scraped_score.last == @fixture.away_team_score)
      home && away
    end

    def get_scores_for_match(match)
      scores = match.search('.fi-s__scoreText')
      return nil unless scores&.text&.include?('-')
      scores&.text&.split('-')&.map(&:to_i)
    end
  end
end
