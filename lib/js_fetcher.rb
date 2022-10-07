# frozen_string_literal: true

require 'selenium-webdriver'
# require 'webdrivers/chromedriver'

module JsFetcher
  def self.fetch(url)
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    driver = Selenium::WebDriver.for(:chrome, options: options)
    driver.manage.timeouts.implicit_wait = 5

    begin
      driver.get(url)
      driver.execute_script("return document.getElementsByTagName('html')[0].innerHTML")
    ensure
      driver.quit
    end
  end
end
