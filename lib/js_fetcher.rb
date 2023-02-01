# frozen_string_literal: true

require 'selenium-webdriver'

module JsFetcher
  def self.fetch(url)
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--disable-blink-features=AutomationControlled')
    driver = Selenium::WebDriver.for(:chrome, options: options)
    driver.manage.timeouts.implicit_wait = 5

    begin
      driver.get(url)
      sleep(5)
      driver.page_source
    ensure
      driver.quit
    end
  end
end
