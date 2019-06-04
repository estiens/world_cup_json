module ChromeBrowserHelper
  def self.browser
    if chrome_path = ENV['GOOGLE_CHROME_BIN']
      Selenium::WebDriver::Chrome.path = chrome_path
    end
    options = Selenium::WebDriver::Chrome::Options.new
    driver = Selenium::WebDriver.for :chrome, options: options
    chrome_dir = Rails.root.join('tmp', 'chrome')
    FileUtils.mkdir_p(chrome_dir)
    user_data_dir = "--user-data-dir=#{chrome_dir}"
    options.add_argument user_data_dir
    options.add_argument "window-size=800x600"
    options.add_argument "headless"
    options.add_argument "disable-gpu"
    options.add_argument 'disable-setuid-sandbox'
    options.add_argument 'disable-dev-shm-usage'
    options.add_argument 'single-process'
    if chrome_bin = ENV["GOOGLE_CHROME_SHIM"]
      options.add_argument "--no-sandbox"
      options.binary = chrome_bin
    end
    Watir::Browser.new :chrome, options: options
  end
end