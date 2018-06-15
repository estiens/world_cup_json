require 'clockwork'
require File.expand_path('../../config/boot',        __FILE__)
require File.expand_path('../../config/environment', __FILE__)
require 'rake'

module Clockwork
  handler do |job|
    puts "Running #{job}"
  end

  # every(1.minute, "scrape_matches") {
  #   rake = Rake::Application.new
  #   Rake.application = rake
  #   Rake::Task.define_task(:environment)
  #   load "#{Rails.root}/lib/tasks/match_scraper.rake"
  #   rake['fifa:get_all_matches'].invoke
  #   rake['fifa:get_events'].invoke
  # }
  seconds = rand(20..29)
  every(seconds.seconds, 'Get Matches') { `rake fifa:get_all_matches` }

  seconds = rand(61..70)
  every(seconds.seconds, 'Get Events') { `rake fifa:get_events` }
end
