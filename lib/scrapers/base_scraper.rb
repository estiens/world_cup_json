module Scrapers
  class BaseScraper

    def initialize(url: nil, match: nil)
      @url = url
      @match = match
      @page = scrape_page_from_url
    end

    private

    def scrape_page_from_url
      return nil unless @url
      opts = { headless: true }
      if (chrome_bin = ENV.fetch('GOOGLE_CHROME_SHIM', nil))
        opts[:options] = { binary: chrome_bin }
      end
      browser = Watir::Browser.new :chrome, opts
      browser.goto(@url)
      @page = Nokogiri::HTML(browser.html)
    end
  end
end
