require "base64"
require "pp"
require "rubygems"
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

module UsaSearch
  class Selenium < Sauce::Selenium
    attr_reader :locale

    def initialize(options)
      @locale = options.delete(:locale)
      super(options)
    end

    def search_as_you_type(locator, text)
      type(locator, firefox? ? "" : text)
      type_keys(locator, text)
    end

    def firefox?
      @config.browser == "firefox"
    end

    def capture_to_file(name, wait=true)
      wait_for_page_to_load if wait
      $stdout.putc "."
      $stdout.flush
      @@steps ||= Hash.new { |h, k| h[k] = 0 }

      browser_identifier = "#{locale}-#{@config.browser}-#{@config.browser_version}-#{@config.os}"
      report_path = File.dirname(__FILE__) + "/../report/" + browser_identifier

      png = capture_screenshot_to_string
      FileUtils.mkdir_p(report_path)
      File.open(report_path + "/%03i-%s-screenshot.png" % [@@steps[browser_identifier]+=1, name], 'wb') do |f|
        f.write(Base64.decode64(png))
        f.close
      end
    end
  end
end

class Script < Struct.new(:browser, :locale)
  attr_reader :selenium
  alias_method :page, :selenium

  def before
    description = [locale, browser].join(" ")
    @selenium = UsaSearch::Selenium.new({:os => browser.os, :browser => browser.browser, :browser_version => browser.browser_version, :job_name => "#{description}", :locale => locale})
    @selenium.start
  end

  def after
    @selenium.try(:stop)
  end

  def run
    before
    run_script
    run_en_only_script if locale.to_s == "en"
  ensure
    after
  end

  def t(key)
    I18n.t(key, :locale => locale)
  end
end
