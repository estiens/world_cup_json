require Rails.root.join('lib/new_scraper_clock.rb')

Dir["#{Rails.root}/lib/scrapers/*.rb"].each { |file| require file }
