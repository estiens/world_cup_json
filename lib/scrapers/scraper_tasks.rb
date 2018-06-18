# frozen_string_literal: true

module Scrapers
  class ScraperTasks
    def self.scrape_old_matches; end

    def self.scrape_current_matches; end

    def self.scrape_for_goals; end

    def self.scrape_old_events
      matches = Match.completed
      matches.each { |m| scrape_events(m) }
    end

    def self.scrape_for_events
      matches = Match.today.where.not(status: 'completed')
      puts 'No current matches for events' if matches.empty?
      matches.each { |m| scrape_events(m) }
    end

    def self.scrape_old_stats
      matches = Match.completed.where(stats_complete: false)
      puts 'No old stats to scrape' if matches.empty?
      matches.each { |m| scrape_stats(m) }
    end

    def self.scrape_for_stats
      matches = Match.today.not_future.where.not(stats_complete: true)
      puts 'No current matches for stats' if matches.empty?
      matches.each { |m| scrape_stats(m) }
    end

    def self.scrape_events(match)
      scraper = Scrapers::EventScraper.new(match: match)
      scraper.scrape
    rescue Selenium::WebDriver::Error
      puts "Event scraper failure for #{m.name}"
    end

    def self.scrape_stats(match)
      scraper = Scrapers::FactScraper.new(match: match)
      scraper.scrape
    rescue Selenium::WebDriver::Error
      puts "Stats scraper failure for #{m.name}"
    end
  end
end
