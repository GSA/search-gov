require File.dirname(__FILE__) + "/support/sauce.rb"
require 'parallel'
require 'pp'

BROWSERS = [
    Browser.new("Windows 2003", "iexplore", "6."),
    Browser.new("Windows 2003", "iexplore", "7."),
    Browser.new("Windows 2003", "iexplore", "8."),
    Browser.new("Windows 2003", "firefox", "3."),
    Browser.new("Windows 2003", "safari", "4."),
    Browser.new("Windows 2003", "googlechrome", ""),
]

LOCALES = ["es", "en"]

class BrowserScript < Script
  def run_script
    page.open "/"
    capture_page(page, "home")

    page.type "search_query", "snow"
    page.click "search_button"
    capture_page(page, "search_snow")

    page.click "link=Images"
    capture_page(page, "image_search_snow")

    page.type "search_query", "fire"
    page.click "search_button"
    capture_page(page, "image_search_fire")
  end
end

class LocaleScript < Script
  def run_script
    page.open "/?locale=#{locale}"
    capture_page(page, "home", locale)

    page.type "search_query", "snow"
    page.click "search_button"
    capture_page(page, "search_snow", locale)

    page.click "link=#{t :images}"
    capture_page(page, "image_search_snow", locale)

    page.type "search_query", "fire"
    page.click "search_button"
    capture_page(page, "image_search_fire", locale)
  end
end

scripts = BROWSERS.collect do |browser|
  BrowserScript.new(browser)
end

scripts += BROWSERS.collect do |browser|
  LOCALES.collect do |locale|
    LocaleScript.new(browser, locale)
  end
end.flatten

Parallel.each(scripts, :in_threads => 6) do |script|
  script.run
end
