RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, js: true, type: :system) do
    driven_by :selenium_chrome_headless
  end

  config.after(:each, js: true, type: :system) do
    Capybara.current_session.driver.quit
  end
end
