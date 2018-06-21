# frozen_string_literal: true

require 'clockwork'
require File.expand_path('../config/boot',        __dir__)
require File.expand_path('../config/environment', __dir__)
require 'rake'

module Clockwork
  every(30.seconds, 'scrapers on lock') do
    `rake scraper:run_scraper`
  end

  every(1.hour, 'hourly cleanup') do
    `rake scraper:hourly_cleanup`
  end

  every(12.hours, 'nightly_cleanup') do
    `rake scraper:nightly_cleanup`
  end
end
