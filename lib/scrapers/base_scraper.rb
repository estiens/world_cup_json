# frozen_string_literal: true

module Scrapers
  class BaseScraper
    attr_accessor :browser, :page

    def initialize
      @browser = ChromeBrowserHelper.browser
      @page = nil
    end

    private

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
