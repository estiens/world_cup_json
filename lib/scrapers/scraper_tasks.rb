# frozen_string_literal: true

module Scrapers
  class ScraperTasks
    def self.scrape_old_matches; end

    def self.scrape_current_matches; end

    def self.force_scrape_old_events
      matches = Match.completed
      matches.each { |m| scrape_events(match: m, force: true) }
      @locked = false
      puts 'old events force scraped successfully'
    end

    def self.scrape_for_events
      matches = Match.not_future.where.not(status: 'completed')
      if matches.empty?
        puts 'No current matches for events'
      else
        matches.each { |m| scrape_events(match: m) }
        puts "event scraping done for #{matches.map(&:name).join(',')}"
      end
      @locked = false
    end

    def self.force_scrape_old_stats
      matches = Match.completed
      matches.each { |m| scrape_stats(match: m, force: true) }
      @locked = false
      puts 'old stats force scraped successfully'
    end

    def self.scrape_old_stats
      matches = Match.completed.where(stats_complete: false)
      puts 'No old stats to scrape' if matches.empty?
      matches.each { |m| scrape_stats(match: m) }
      @locked = false
      puts 'old stats scraped successfully'
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
