# frozen_string_literal: true

require 'clockwork'
require File.expand_path('../config/boot',        __dir__)
require File.expand_path('../config/environment', __dir__)
require 'rake'

module Clockwork
  every(45.seconds, 'scrapers on lock') do
    `rake scraper:run_scraper`
  end
end
