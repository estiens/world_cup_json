require 'clockwork'
require File.expand_path('../../config/boot',        __FILE__)
require File.expand_path('../../config/environment', __FILE__)
require 'rake'

module Clockwork

  handler do |job|
    puts "Running #{job}"
  end

  every(1.minute, "scrape_matches") {
    rake = Rake::Application.new
    Rake.application = rake
    Rake::Task.define_task(:environment)
    load "#{Rails.root}/lib/tasks/match_scraper.rake"
    rake['fifa:get_all_matches'].invoke
  }

  every(1.minute, "scrape_events") {
    rake = Rake::Application.new
    Rake.application = rake
    Rake::Task.define_task(:environment)
    load "#{Rails.root}/lib/tasks/event_scraper.rake"
    rake['fifa:get_all_events'].invoke
  }

end