require 'clockwork'
require File.expand_path('../../config/boot',        __FILE__)
require File.expand_path('../../config/environment', __FILE__)
require 'rake'

module Clockwork
  handler do |job|
    puts "Running #{job}"
  end

  seconds = rand(20..29)
  every(seconds.seconds, 'Get Matches') do
    if Match.today.count == Match.today.where(status: 'completed').count
      puts 'Scores All Done For Today'
    else
      `rake fifa:get_all_matches`
    end
  end

  seconds = rand(61..70)
  every(seconds.seconds, 'Get Events') do
    if Match.today.count == Match.today.where(status: 'completed').count
      puts 'Events All Done For Today'
    else
      `rake fifa:get_events`
    end
  end

  every(5.minutes, 'Scrape Old Stats') do
    if Match.completed.count == Match.where(stats_complete: true).count
      puts 'No Old Stats to Scrape'
    else
      Scrapers::ScraperTasks.scrape_old_events
    end
  end

  stats_seconds = rand(45..75)
  every(stats_seconds.seconds, 'Scrape Current Stats') do
    if Match.today.count == Match.today.where(stats_complete: true).count
      puts 'No current stats to scrape'
    else
      Scrapers::ScraperTasks.scrape_for_stats
    end
  end
end
