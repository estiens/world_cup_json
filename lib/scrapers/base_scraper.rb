# frozen_string_literal: true

module Scrapers
  class BaseScraper
    attr_accessor :browser, :page

    def initialize(url: nil, match: nil)
      @url = url
      @match = match
      @browser = nil
      @page = nil
      scrape_page_from_url
    end

    private

    def scrape_page_from_url
      opts = { headless: true }
      if (chrome_bin = ENV.fetch('GOOGLE_CHROME_SHIM', nil))
        opts[:options] = { binary: chrome_bin }
      end
      @browser = Watir::Browser.new :chrome, opts
      @browser.goto(@url)
      @page = @browser.html
    end
  end
end
