# frozen_string_literal: true

require 'clockwork'
require File.expand_path('../config/boot',        __dir__)
require File.expand_path('../config/environment', __dir__)
require 'rake'
require 'platform-api'

def scale_up
  if ENV['PLATFORM_OAUTH_TOKEN']
    heroku = PlatformAPI.connect_oauth(ENV['PLATFORM_OAUTH_TOKEN'])
    heroku.formation.update('world-cup-json', 'clock', size: 'standard-2x')
    heroku.formation.update('world-cup-json', 'web', quantity: 3)
  end
end

def scale_middle
  if ENV['PLATFORM_OAUTH_TOKEN']
    heroku = PlatformAPI.connect_oauth(ENV['PLATFORM_OAUTH_TOKEN'])
    heroku.formation.update('world-cup-json', 'clock', size: 'standard-2x')
    heroku.formation.update('world-cup-json', 'web', quantity: 2)
  end
end

def scale_down
  if ENV['PLATFORM_OAUTH_TOKEN']
    heroku = PlatformAPI.connect_oauth(ENV['PLATFORM_OAUTH_TOKEN'])
    heroku.formation.update('world-cup-json', 'clock', size: 'standard-1x')
    heroku.formation.update('world-cup-json', 'web', quantity: 1)
  end
end

# running longer jobs on heroku scheduler to run in one off bigger dynos
# hacking around here and just slowing down scraping by blocking clockwork
module Clockwork
  every(30.seconds, 'scrapers on lock') do
    if Match.in_progress.count.positive?
      puts 'scraping at speed captain!'
      scale_up
    elsif Match.next.present? && (Time.now + 1.hour) > Match.next.datetime
      puts 'sleeping for a bit'
      scale_middle
      sleep(30)
    else
      puts 'not scraping so hard and fast right now'
      scale_down
      sleep(120)
    end
    `rake scraper:run_scraper`
  end
  every(10.minutes, 'Backup Check') do
    `rake scraper:backup_check`
  end
end
