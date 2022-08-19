require 'selenium-webdriver'

module JsFetcher
  def self.fetch(url)
    options = Selenium::WebDriver::Chrome::Options.new(args: ['headless'])
    # Some test sites return a 403 when access with selenium webdriver.
    # The following user-agent override should be removed when testing is complete.
    options.add_argument("user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36")
    driver = Selenium::WebDriver.for(:chrome, options: options)
    wait = Selenium::WebDriver::Wait.new(:timeout => 5)

    begin
      driver.get(url)
      wait.until{document_initialised driver}
    ensure
      driver.quit
    end
  end

  def self.document_initialised(driver)
    driver.execute_script("return document.getElementsByTagName('html')[0].innerHTML")
  end
end
