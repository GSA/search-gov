require "spec_helper"
require "base64"

describe "search.usa.gov" do
  it "should have image searches" do
    page.open "/"
    page.is_text_present("Advanced Search").should be_true
    capture_page(page, "home")

    page.type "search_query", "snow"
    page.click "search_button"
    page.wait_for_page_to_load
    capture_page(page, "search_snow")

    page.click "link=Images"
    page.wait_for_page_to_load
    capture_page(page, "image_search_snow")

    page.type "search_query", "fire"
    page.click "search_button"
    page.wait_for_page_to_load
    capture_page(page, "image_search_fire")


  end
end

def capture_page(page, page_name)
  @@step ||= 0
  png = page.capture_screenshot_to_string
  File.open(File.dirname(__FILE__) + "/screenshots/%03i-%s-screenshot.png" % [@@step+=1, page_name], 'wb') do |f|
    f.write(Base64.decode64(png))
    f.close
  end
end
