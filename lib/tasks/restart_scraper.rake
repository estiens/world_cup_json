require 'platform-api'

namespace :scraper do
  desc 'restarts scraper b/c of chrome memory leaks'
  task restart_scraper: :environment do
    heroku = PlatformAPI.connect_oauth(ENV['PLATFORM_OAUTH_TOKEN'])
    heroku.dyno.restart('world-cup-json', 'clock.1')
    if Match.in_progress.count.positive?
      heroku.formation.update('world-cup-json', 'web', quantity: 3)
    elsif Match.today.future.count.positive?
      heroku.formation.update('world-cup-json', 'web', quantity: 2)
    else
      heroku.formation.update('world-cup-json', 'web', quantity: 1)
    end
  end
end
