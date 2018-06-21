# frozen_string_literal: true

module Scrapers
  class ScraperTasks
    def self.verify_past_scores
      scrape_matches(event: :verify_past_scores)
    end

    def self.overwrite_old_matches
      scrape_matches(event: :write_past_matches, force: true)
    end

    def self.scrape_old_matches
      scrape_matches(event: :write_past_matches, force: false)
    end

    def self.scrape_future_matches
      scrape_matches(event: :write_future_matches, force: false)
    end

    def self.overwrite_future_matches
      scrape_matches(event: :write_future_matches, force: true)
    end

    def self.check_for_live_game
      scrape_matches(event: :check_for_live_status)
    end

    def self.force_scrape_old_events
      matches = Match.completed
      matches.each { |m| scrape_events(match: m, force: true) }
      puts 'old events force scraped successfully'
      @locked = false
    end

    def self.fix_broken_scores
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

    def self.scrape_for_events
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

    def self.force_scrape_old_stats
      matches = Match.completed
      matches.each { |m| scrape_stats(match: m, force: true) }
      puts 'old stats force scraped successfully'
      @locked = false
    end

    def self.scrape_old_stats
      matches = Match.completed.where(stats_complete: false)
      puts 'No old stats to scrape' if matches.empty?
      matches.each { |m| scrape_stats(match: m) }
      puts 'old stats scraped successfully'
      @locked = false
    end

    def self.scrape_for_stats
      matches = Match.not_future.where.not(stats_complete: true)
      if matches.empty?
        puts 'No current matches for stats'
      else
        matches.each { |m| scrape_stats(match: m) }
        puts "stats scraping done for #{matches.map(&:name).join(',')}"
      end
      @locked = false
    end

    def self.scrape_events(match:, force: false)
      sleep(5) if @locked
      @locked = true
      thread = Thread.new do
        scraper = Scrapers::EventScraper.new(match: match, force: force)
        scraper.scrape
      end
      @locked = false if thread.join
    end

    def self.scrape_matches(event:, force: false)
      sleep(5) if @locked
      @locked = true
      thread = Thread.new do
        scraper = Scrapers::MatchScraper.new(force: force)
        scraper.send(event)
      end
      @locked = false if thread.join
    end

    def self.scrape_stats(match:, force: false)
      sleep(5) if @locked
      @locked = true
      thread = Thread.new do
        scraper = Scrapers::FactScraper.new(match: match, force: force)
        scraper.scrape
      end
      @locked = false if thread.join
    end
  end
end
