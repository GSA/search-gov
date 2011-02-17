INSTALL_SAUCE_MESSAGE = "To enable sauce integration, run 'gem install sauce -v 0.15.1 && sauce configure  usa_search 5060039c-fa2b-403c-9fef-617142894173'"
begin
  gem 'sauce', '0.15.1'
  require 'sauce'

  Sauce.config do |conf|
    conf.browser_url = "http://demo:***REMOVED***@searchdemo.usa.gov"
    conf.browsers = [
        ["Windows 2003", "iexploreproxy", "6."],
        ["Windows 2003", "firefox", "3."],
        ["Windows 2003", "safari", "4."],
    ]
  end

  class ScreenshotExampleGroup < Spec::Example::ExampleGroup
    attr_reader :selenium
    alias_method :page, :selenium
    alias_method :s, :selenium

    def execute(*args)
      config = Sauce::Config.new
      description = [self.class.description, self.description].join(" ")
      config.browsers.each do |os, browser, version|
        @selenium = Sauce::Selenium.new({:os => os, :browser => browser, :browser_version => version, :job_name => "#{description}"})
        @selenium.start
        begin
          super(*args)
        ensure
          @selenium.stop
        end
      end
    end
  end

rescue LoadError => e
  $stderr.puts INSTALL_SAUCE_MESSAGE
end

class ScreenshotExampleGroup < Spec::Example::ExampleGroup
  before :all do
    unless defined?(Sauce)
      raise INSTALL_SAUCE_MESSAGE
    end
  end
  Spec::Example::ExampleGroupFactory.register(:screenshot, self)
end
