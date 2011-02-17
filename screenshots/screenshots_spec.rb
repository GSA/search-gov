require File.dirname(__FILE__) + "/support/sauce.rb"

BROWSERS = [
    Browser.new("Windows 2003", "iexplore", "6."),
    Browser.new("Windows 2003", "iexplore", "7."),
    Browser.new("Windows 2003", "iexplore", "8."),
    Browser.new("Windows 2003", "firefox", "3."),
    Browser.new("Windows 2003", "safari", "4."),
    Browser.new("Windows 2003", "googlechrome", ""),
]


BROWSERS.each do |browser|
  describe browser.to_s, :type => :screenshot do
    before :all do
      @browser = browser
    end

    it "should visit the home page" do
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

end
