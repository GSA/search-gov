# frozen_string_literal: true

require 'selenium-webdriver'

module JsFetcher
  def self.fetch(url)
    options = Selenium::WebDriver::Options.firefox
    options.add_argument('-headless')
    options.add_preference('browser.sessionstore.resume_from_crash', false)
    options.add_preference('browser.tabs.warnOnClose', false)
    options.add_preference('general.useragent.override', DEFAULT_USER_AGENT)

    driver = Selenium::WebDriver.for(:firefox, options:)

    driver.manage.timeouts.implicit_wait = 5
    driver.manage.timeouts.page_load = 30

    begin
      driver.get(url)
      sleep(5)
      driver.page_source
    ensure
      driver.quit
    end
  end
end
