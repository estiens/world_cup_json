require Rails.root.join('lib/new_scraper_clock.rb')
require Rails.root.join('lib/tasks/2022/setup.rb')

Dir["#{Rails.root}/lib/scrapers/*.rb"].each { |file| require file }
