require 'platform-api'

namespace :scraper do
  desc 'restarts scraper b/c of chrome memory leaks'
  task restart_scraper: :environment do
    heroku = PlatformAPI.connect_oauth(ENV['PLATFORM_OAUTH_TOKEN'])
    heroku.dyno.restart('world-cup-json', 'clock.1')
  end
end
