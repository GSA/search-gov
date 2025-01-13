Capybara.register_driver :selenium_firefox_headless do |app|
  options = Selenium::WebDriver::Options.firefox
  options.args << '-headless'
  options.args << '--window-size=1200,768'

  Capybara::Selenium::Driver.new(app, browser: :firefox, options: options)
end
