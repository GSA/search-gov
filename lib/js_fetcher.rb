module JsFetcher
  def self.fetch(url)
    options = Selenium::WebDriver::Chrome::Options.new(args: ['headless'])
    driver = Selenium::WebDriver.for(:chrome, options: options)
    puts driver.get(url)
  end
end
