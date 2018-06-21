require 'platform-api'

def upcoming_match?
  return nil unless Match.next
  (Time.now + 1.hour) > Match.next.datetime
end

def recently_ended_match?
  return nil unless Match.recently_completed
  (Time.now - 1.hour) < Match.recently_completed.last_event_update_at
end

def scale_for_matches
  if Match.in_progress.count.positive?
    heroku.formation.update('world-cup-json', 'web', quantity: 3)
  elsif upcoming_match?
    heroku.formation.update('world-cup-json', 'web', quantity: 2)
  elsif recently_ended_match?
    heroku.formation.update('world-cup-json', 'web', quantity: 2)
  else
    heroku.formation.update('world-cup-json', 'web', quantity: 1)
  end
end

namespace :scraper do
  desc 'restarts scraper b/c of chrome memory leaks'
  task restart_scraper: :environment do
    heroku = PlatformAPI.connect_oauth(ENV['PLATFORM_OAUTH_TOKEN'])
    heroku.dyno.restart('world-cup-json', 'clock.1')
    if ENV['SCALE_FOR_MATCHES']
      scale_for_matches
    end
  end
end
