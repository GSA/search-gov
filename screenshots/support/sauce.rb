require "base64"
require "rubygems"
require "spec"
require "active_support"

I18n.load_path = Dir[File.dirname(__FILE__) + '/../../config/locales/*.yml']


begin
  gem 'sauce'
  require 'sauce'
rescue LoadError => e
  $stderr.puts "To enable sauce integration, run 'gem install sauce"
  raise e
end

Sauce.config do |conf|
  conf.browser_url = "http://demo:***REMOVED***@searchdemo.usa.gov"
  conf.username = "usa_search"
  conf.access_key = "5060039c-fa2b-403c-9fef-617142894173"
end

class Browser < Struct.new(:os, :browser, :browser_version)
  def to_s
    "#{browser} #{browser_version} (#{os})"
  end
end

module SauceHelper
  def capture_page(page, page_name, locale = nil)
    page.wait_for_page_to_load
    $stdout.putc "."
    $stdout.flush
    @@steps ||= Hash.new {|h,k| h[k] = 0}
    browser_hash = JSON.parse(page.browser_string)
    browser_identifier = "#{"#{locale}-" if locale}#{browser_hash["browser"]}-#{browser_hash["browser-version"]}-#{browser_hash["os"]}"
    report_path = File.dirname(__FILE__) + "/../report/" + browser_identifier

    png = page.capture_screenshot_to_string
    FileUtils.mkdir_p(report_path)
    File.open(report_path + "/%03i-%s-screenshot.png" % [@@steps[browser_identifier]+=1, page_name], 'wb') do |f|
      f.write(Base64.decode64(png))
      f.close
    end
  end
end

class ScreenshotExampleGroup < Spec::Example::ExampleGroup
  include SauceHelper
  attr_reader :selenium
  alias_method :page, :selenium

  before :each do
    description = [self.class.description, self.description].join(" ")
    @selenium = Sauce::Selenium.new({:os => @browser.os, :browser => @browser.browser, :browser_version => @browser.browser_version, :job_name => "#{description}"})
    @selenium.start
  end

  after :each do
    @selenium.stop
  end

  Spec::Example::ExampleGroupFactory.register(:screenshot, self)

end

class Script < Struct.new(:browser, :locale)
  include SauceHelper

  attr_reader :selenium
  alias_method :page, :selenium

  def before
    description = [locale, browser].join(" ")
    @selenium = Sauce::Selenium.new({:os => browser.os, :browser => browser.browser, :browser_version => browser.browser_version, :job_name => "#{description}"})
    @selenium.start
  end

  def after
    @selenium.try(:stop)
  end

  def run
    before
    run_script
  ensure
    after
  end

  def t(key)
    I18n.t(key, :locale => locale)
  end
end
