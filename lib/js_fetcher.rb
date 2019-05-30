# frozen_string_literal: true

require 'selenium-webdriver'
require 'webdrivers/chromedriver'

module JsFetcher
  def self.fetch(url)
    options = Selenium::WebDriver::Chrome::Options.new(args: ['headless'])
    driver = Selenium::WebDriver.for(:chrome, options: options)
    wait = Selenium::WebDriver::Wait.new(timeout: 5)

    begin
      driver.get(url)
      wait.until { document_initialised(driver) }
    ensure
      driver.quit
    end
  end

  def self.document_initialised(driver)
    driver.execute_script("return document.getElementsByTagName('html')[0].innerHTML")
  end
end
