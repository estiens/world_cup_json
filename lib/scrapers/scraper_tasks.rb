# frozen_string_literal: true

module Scrapers
  class ScraperTasks
    # class methods to be run on schedules
    # many will return early ideally as there
    # will be nothing left to scrape

    # only scrape for game status until it switches
    # then look for goals/events/stats
    def self.scrape_your_heart_out
      me = new
      if Match.in_progress.count.positive?
        puts 'Scraping live games, thats what I love!'
        me.get_match_json
        me.scrape_for_events
        me.scrape_for_stats
      end
      if Match.today.future.count.positive?
        me.check_for_live_game
        puts 'is a game on yet?'
      end
    end

    def self.check_for_live_game_occasionally
      me = new
      me.check_for_live_game
    end

    # sometimes FIFA adds stats/events after the match closes
    def self.hourly_cleanup
      me = new
      me.scrape_old_matches
      matches = Match.today.completed
      me.force_scrape_old_events(matches: matches)
      me.force_scrape_old_stats(matches: matches)
      me.scrape_future_matches
      me.scrape_for_stats
      me.scrape_for_events
      me.get_match_json
    end

    # def want to make sure nothing got of whack
    def self.nightly_cleanup
      me = new
      me.verify_past_scores
      me.fix_broken_scores
      me.scrape_future_matches
      me.scrape_for_stats
      me.scrape_for_events
    end

    def self.setup_matches_for_json
      Scrapers::JsonScraper.write_fifa_info
    end

    def self.write_old_match_json
      matches = Match.completed
      matches.each do |match|
        Scrapers::JsonScraper.write_all_info_for_match(match.fifa_id)
        sleep(5)
      end
    end

    # instance methods - can be run as one-offs

    def initialize
      # lock to keep chromedriver from freezing
      @locked = false
    end

    def get_match_json
      matches = Match.not_future.where(stats_complete: false)
      if matches.empty?
        puts 'No current matches for JSON'
      else
        matches.each do |m|
          Scrapers::JsonScraper.write_all_info_for_match(m.fifa_id)
          sleep(2)
        end
      end
    end

    def fix_times
      scrape_matches(event: :fix_times)
    end

    def verify_past_scores
      scrape_matches(event: :verify_past_scores)
    end

    def overwrite_old_matches
      scrape_matches(event: :write_past_matches, force: true)
    end

    def scrape_old_matches
      scrape_matches(event: :write_past_matches, force: false)
    end

    def scrape_future_matches
      scrape_matches(event: :write_future_matches, force: false)
    end

    def overwrite_future_matches
      scrape_matches(event: :write_future_matches, force: true)
    end

    def check_for_live_game
      scrape_matches(event: :check_for_live_status)
    end

    def fix_broken_scores
      matches = Match.where(status: 'pending_correction')
      if matches.empty?
        puts 'No current broken scores'
      else
        matches.each do |m|
          puts "Scraping Events and Goals for #{m.name}"
          scrape_events(match: m)
        end
        puts "event scraping done for #{matches.map(&:name).join(',')}"
      end
      @locked = false
    end

    def force_scrape_old_events(matches: nil)
      matches ||= Match.completed
      matches.each { |m| scrape_events(match: m, force: true) }
      puts 'old events force scraped successfully'
      @locked = false
    end

    def scrape_for_events
      matches = Match.not_future.where.not(events_complete: true)
      if matches.empty?
        puts 'No current matches for events'
      else
        matches.each do |m|
          puts "Scraping Events and Goals for #{m.name}"
          scrape_events(match: m)
        end
        puts "event scraping done for #{matches.map(&:name).join(',')}"
      end
      @locked = false
    end

    def force_scrape_old_stats(matches: nil)
      matches ||= Match.completed
      matches.each { |m| scrape_stats(match: m, force: true) }
      puts 'old stats force scraped successfully'
      @locked = false
    end

    def scrape_for_stats
      matches = Match.not_future.where(stats_complete: false)
      if matches.empty?
        puts 'No current matches for stats'
      else
        matches.each { |m| scrape_stats(match: m) }
        puts "stats scraping done for #{matches.map(&:name).join(',')}"
      end
      @locked = false
    end

    private

    def scrape_events(match:, force: false)
      sleep(1) while @locked
      @locked = true
      scraper = Scrapers::EventScraper.new(match: match, force: force)
      scraper.scrape
      @locked = false
    end

    def scrape_matches(event:, force: false)
      sleep(1) while @locked
      @locked = true
      scraper = Scrapers::MatchScraper.new(force: force)
      scraper.send(event)
      @locked = false
    end

    def scrape_stats(match:, force: false)
      sleep(1) while @locked
      @locked = true
      scraper = Scrapers::FactScraper.new(match: match, force: force)
      scraper.scrape
      @locked = false
    end
  end
end
