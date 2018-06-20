# frozen_string_literal: true

require 'clockwork'
require File.expand_path('../config/boot',        __dir__)
require File.expand_path('../config/environment', __dir__)
require 'rake'

module Clockwork
  handler do |job|
    puts "Running #{job}"
  end

  seconds = rand(25..35)
  every(seconds.seconds, 'Get Matches') do
    if Match.today.count == Match.today.completed.count
      puts 'Scores All Done For Today'
    else
      `rake fifa:get_all_matches`
    end
  end

  seconds = if Match.today.not_completed.not_future.count.positive?
              rand(61..70)
            else
              rand(115..125)
            end
  every(seconds.seconds, 'Get Events') do
    if Match.today.count == Match.today.completed.count
      puts 'Events All Done For Today'
    else
      `rake fifa:get_events`
    end
  end

  every(10.minutes, 'Scrape Old Stats') do
    if Match.completed.count == Match.where(stats_complete: true).count
      puts 'No Old Stats to Scrape'
    else
      Scrapers::ScraperTasks.scrape_old_stats
    end
  end

  stats_seconds = if Match.in_progress.count.positive?
                    rand(55..65)
                  else
                    rand(115..125)
                  end
  every(stats_seconds.seconds, 'Scrape Current Stats') do
    if Match.today.count == Match.today.where(stats_complete: true).count
      puts 'No current stats to scrape'
    else
      Scrapers::ScraperTasks.scrape_for_stats
    end
  end
end
