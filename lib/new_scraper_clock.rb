# frozen_string_literal: true

require 'clockwork'
require File.expand_path('../config/boot',        __dir__)
require File.expand_path('../config/environment', __dir__)
require 'rake'

module Clockwork
  every(30.seconds, 'scrapers on lock') do
    waiting = rand(30)
    puts "waiting #{waiting}"
    sleep(waiting)
    Scrapers::ScraperTasks.scrape_for_goals
  end
end
