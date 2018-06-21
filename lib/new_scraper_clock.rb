# frozen_string_literal: true

require 'clockwork'
require File.expand_path('../config/boot',        __dir__)
require File.expand_path('../config/environment', __dir__)
require 'rake'

module Clockwork
  every(25.seconds, 'scrapers on lock') do
    @runner ||= Scrapers::ScraperTasks.new
    runner.check_for_live_game unless Match.in_progress.count.positive?
    runner.scrape_for_events
    game_time_stuff
  end

  every(70.seconds, 'stats scraper fire') do
    @runner ||= Scrapers::ScraperTasks.new
    runner.scrape_for_stats
  end
end
