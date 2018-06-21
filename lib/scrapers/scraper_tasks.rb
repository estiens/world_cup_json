# frozen_string_literal: true

module Scrapers
  class ScraperTasks

    def initialize
      # lock to keep chromedriver from freezing
      @locked = false
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

    def force_scrape_old_events
      matches = Match.completed
      matches.each { |m| scrape_events(match: m, force: true) }
      puts 'old events force scraped successfully'
      @locked = false
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

    def force_scrape_old_stats
      matches = Match.completed
      matches.each { |m| scrape_stats(match: m, force: true) }
      puts 'old stats force scraped successfully'
      @locked = false
    end

    def scrape_old_stats
      matches = Match.completed.where(stats_complete: false)
      puts 'No old stats to scrape' if matches.empty?
      matches.each { |m| scrape_stats(match: m) }
      puts 'old stats scraped successfully'
      @locked = false
    end

    def scrape_for_stats
      matches = Match.not_future.where.not(stats_complete: true)
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
