module Scrapers
  class ScraperTasks

    def self.scrape_old_matches
    end

    def self.scrape_current_matches
    end

    def self.scrape_for_goals
    end

    def self.scrape_old_events
    end

    def self.scrape_for_events
    end

    def self.scrape_old_stats
      matches = Match.completed
      matches.each { |m| scrape_stats(m) }
    end

    def self.scrape_live_stats
      match = Match.in_progress.first
      scrape_stats(match)
    end

    def self.scrape_for_stats
      matches = Match.today.where.not(status: 'future')
      puts 'No current matches for stats' if matches.empty?
      matches.each { |m| scrape_stats(m) }
    end

    def self.scrape_stats(match)
      scraper = Scrapers::FactScraper.new(match: match)
      scraper.scrape
    rescue Selenium::WebDriver::Error
      puts "Stats scraper failure for #{m.name}"
    end
  end
end
