require 'selenium-webdriver'

module JsFetcher
  def self.fetch(url)
    options = Selenium::WebDriver::Chrome::Options.new(args: ['headless'])
    driver = Selenium::WebDriver.for(:chrome, options: options)
    driver.get(url)
    driver.page_source
  end
end
