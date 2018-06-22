# frozen_string_literal: true

require 'clockwork'
require File.expand_path('../config/boot',        __dir__)
require File.expand_path('../config/environment', __dir__)
require 'rake'
require 'platform-api'

def scale_middle
  heroku = PlatformAPI.connect_oauth(ENV['PLATFORM_OAUTH_TOKEN'])
  heroku.formation.update('world-cup-json', 'clock', size: 'standard-2x')
end

def scale_down
  heroku = PlatformAPI.connect_oauth(ENV['PLATFORM_OAUTH_TOKEN'])
  heroku.formation.update('world-cup-json', 'clock', size: 'standard-1x')
end

# running longer jobs on heroku scheduler to run in one off bigger dynos
# hacking around here and just slowing down scraping by blocking clockwork
module Clockwork
  every(30.seconds, 'scrapers on lock') do
    if Match.in_progress.count.positive?
      puts 'scraping at speed captain!'
      scale_middle
    elsif Match.today.future.count.positive?
      puts 'sleeping for a bit'
      sleep(30)
    else
      scale_down
      sleep(120)
      puts "not scraping so hard and fast right now"
    end
    `rake scraper:run_scraper`
  end
end
