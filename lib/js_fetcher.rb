# frozen_string_literal: true

require 'selenium-webdriver'

module JsFetcher
  def self.fetch(url)
    options = Selenium::WebDriver::Options.firefox
    options.add_argument('-headless')
    options.add_preference('browser.sessionstore.resume_from_crash', false)
    options.add_preference('browser.tabs.warnOnClose', false)
    options.add_preference('general.useragent.override', DEFAULT_USER_AGENT)

    begin
      driver = Selenium::WebDriver.for(:firefox, options:)
    rescue StandardError
      # If Firefox fails to launch, Selenium raises before `driver` is
      # assigned, leaving the already-spawned geckodriver running with
      # inherited file descriptors (e.g. MySQL connections). Reap it.
      kill_stray_geckodrivers
      raise
    end

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

  def self.kill_stray_geckodrivers
    pids = `pgrep -P #{Process.pid} -f geckodriver`.split.map(&:to_i)
    pids.each do |pid|
      Process.kill('TERM', pid)
    rescue Errno::ESRCH, Errno::EPERM
      next
    end
  end
  private_class_method :kill_stray_geckodrivers
end
