# frozen_string_literal: true

namespace :scraper do
  desc 'try running as a rake task til we have sidekiq'
  task run_scraper: :environment do
    Scrapers::ScraperTasks.scrape_your_heart_out
  end

  task backup_check: :environment do
    Scrapers::ScraperTasks.check_for_live_game_occasionally
  end

  task hourly_cleanup: :environment do
    Scrapers::ScraperTasks.hourly_cleanup
  end

  task nightly_cleanup: :environment do
    Scrapers::ScraperTasks.nightly_cleanup
  end

  task force_all_new: :environment do
    Scrapers::ScraperTasks.new.overwrite_future_matches
  end

  task force_all_old: :environment do
    Scrapers::ScraperTasks.new.overwrite_old_matches
  end

  task setup_json: :environment do
    Scrapers::ScraperTasks.setup_matches_for_json
  end
end
