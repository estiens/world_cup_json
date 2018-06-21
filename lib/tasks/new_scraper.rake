namespace :scraper do
  desc 'try running as a rake task til we have sidekiq'
  task run_scraper: :environment do
    Scrapers::ScraperTasks.scrape_for_goals
  end
end
