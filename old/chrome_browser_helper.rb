# frozen_string_literal: true

module ChromeBrowserHelper
  def self.browser
    return @browser if @browser
    options = Selenium::WebDriver::Chrome::Options.new
    chrome_dir = Rails.root.join('tmp', 'chrome')
    FileUtils.mkdir_p(chrome_dir)
    user_data_dir = "--user-data-dir=#{chrome_dir}"
    options.add_argument user_data_dir
    options.add_argument '--window-size=800x600'
    options.add_argument '--enable-automation'
    options.add_argument '--disable-infobars'
    options.add_argument '--headless'
    options.add_argument '--disable-gpu'
    options.add_argument '--disable-setuid-sandbox'
    options.add_argument '--disable-dev-shm-usage'
    options.add_argument '--single-process'
    options.add_argument '--remote-debugging-port=9222'
    if chrome_bin = ENV['GOOGLE_CHROME_SHIM']
      options.add_argument '--no-sandbox'
      options.binary = chrome_bin
      Webdrivers.logger.level = :DEBUG
      Selenium::WebDriver::Chrome.path = ENV['GOOGLE_CHROME_BIN']
    end
    @browser = Watir::Browser.new :chrome, options: options
    @browser
  end
end
