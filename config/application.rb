require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module WorldCupJson
  class Application < Rails::Application
    config.load_defaults 7.0
    config.time_zone = "UTC"
    config.eager_load_paths << Rails.root.join("lib")
    config.eager_load_paths << Rails.root.join('lib/scrapers')
  end
end
