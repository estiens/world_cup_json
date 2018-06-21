# frozen_string_literal: true

require 'clockwork'
require File.expand_path('../config/boot',        __dir__)
require File.expand_path('../config/environment', __dir__)
require 'rake'

module Clockwork
  def runner
    @runner ||= Scrapers::ScraperTasks.new
  end

  def game_time_stuff
    runner.check_for_live_game unless Match.in_progress.count.positive?
    runner.scrape_for_events
  end

  def grab_stats
    runner.scrape_for_stats
  end

  every(25.seconds, 'scrapers on lock') do
    game_time_stuff
  end

  every(70.seconds, 'stats scraper fire') do
    grab_stats
  end
end
