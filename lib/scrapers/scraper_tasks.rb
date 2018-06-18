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
      matches = Match.completed.where(status_completed: false)
      puts 'No old stats to scrape' if matches.empty?
      matches.each { |m| scrape_stats(m) }
    end

    def self.scrape_for_stats
      matches = Match.today.where.not(status: 'future')
                     .where.not(stats_complete: true)
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
