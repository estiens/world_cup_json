require_relative 'boot'

require 'rails/all'
require 'good_job/engine'

Bundler.require(*Rails.groups)

module WorldCupJson
  class Application < Rails::Application
    config.load_defaults 7.0
    config.time_zone = 'UTC'
    config.active_job.queue_adapter = :good_job
  end
end
