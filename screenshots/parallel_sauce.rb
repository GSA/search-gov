require File.dirname(__FILE__) + "/support/sauce.rb"

begin
  gem 'parallel'
  require 'parallel'
rescue LoadError => e
  $stderr.puts "Please run 'gem install parallel'"
  raise e
end

BROWSERS = [
    Browser.new("Windows 2003", "iexplore", "6."),
    Browser.new("Windows 2003", "iexplore", "7."),
    Browser.new("Windows 2003", "iexplore", "8."),
    Browser.new("Windows 2003", "firefox", "3."),
    Browser.new("Windows 2003", "safari", "4."),
    Browser.new("Windows 2003", "googlechrome", ""),
]

LOCALES = [
    "es",
    "en"
]

class UsaSearchScript < Script
  def run_script
    page.open "/?locale=#{locale}"
    page.capture_to_file("home")

    page.search_as_you_type("search_query", "bar")
    page.capture_to_file("home_sayt", false)

#    TODO: this works on firefox only at the moment
#    page.key_down("search_query", 40)
#    page.key_down("search_query", 40)
#    page.capture_to_file("home_sayt_selected", false)

#    page.key_down("search_query", 13)
#    page.capture_to_file("home_sayt_follow")

    page.type "search_query", "snow"
    page.click "search_button"
    page.capture_to_file("search_snow")

    page.click "link=#{t :images}"
    page.capture_to_file("image_search_snow")

    page.type "search_query", "fire"
    page.click "search_button"
    page.capture_to_file("image_search_fire")
  end

  def run_en_only_script
    page.open "/"

    page.click "link=Forms"
    page.capture_to_file("forms_landing")

    page.click "link=Recalls"
    page.capture_to_file("recalls_landing")

    page.open "/search?affiliate=affiliatetemplate&query=gov"
    page.capture_to_file("affiliate_default")

    page.search_as_you_type("search_query", "bar")
    page.capture_to_file("affiliate_default_sayt", false)

    page.open "/search?affiliate=affiliatetemplate&query=gov&staged=1"
    page.capture_to_file("affiliate_basic_gray")

    page.search_as_you_type("search_query", "bar")
    page.capture_to_file("affiliate_basic_gray_sayt", false)
  end
end

SCRIPTS = BROWSERS.collect do |browser|
  LOCALES.collect do |locale|
    UsaSearchScript.new(browser, locale)
  end
end.flatten

if $0 == __FILE__
  Parallel.each(SCRIPTS, :in_threads => SCRIPTS.length) do |script|
    script.run
  end
end
