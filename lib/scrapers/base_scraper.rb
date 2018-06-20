# frozen_string_literal: true

module Scrapers
  class BaseScraper
    attr_accessor :browser, :page

    def initialize
      @browser = init_browser
      @page = nil
    end

    private

    def init_browser
      opts = { headless: true }
      if (chrome_bin = ENV.fetch('GOOGLE_CHROME_SHIM', nil))
        opts[:options] = { binary: chrome_bin }
      end
      @browser = Watir::Browser.new :chrome, opts
      @browser.driver.manage.window.resize_to(1920, 1080)
      @browser
    end

    def scrape_page_from_url(before_events: false)
      raise 'Must set url' unless @url
      @browser.goto(@url)
      before_scrape_events if before_events
      @page = Nokogiri::HTML(@browser.html)
    end

    def before_scrape_events
      # override
    end
  end
end
