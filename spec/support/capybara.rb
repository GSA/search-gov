require_relative 'firefox_setup'

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, js: true, type: :system) do
    driven_by :selenium_firefox_headless
  end

  config.after(:each, js: true, type: :system) do
    Capybara.current_session.quit
  end
end
