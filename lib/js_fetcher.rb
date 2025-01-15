# frozen_string_literal: true

require 'selenium-webdriver'

module JsFetcher
  def self.fetch(url)
    options = Selenium::WebDriver::Options.firefox
    options.add_argument('-headless')
    options.add_argument("-user-agent=#{DEFAULT_USER_AGENT}")
    driver = Selenium::WebDriver.for :firefox, options: options
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
