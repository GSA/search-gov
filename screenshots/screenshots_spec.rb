require "base64"
require "rubygems"
require "spec"
require File.dirname(__FILE__) + "/support/sauce.rb"

describe "search.usa.gov", :type => :screenshot do
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
  @@steps ||= Hash.new {|h,k| h[k] = 0}
  browser_hash = JSON.parse(page.browser_string)
  browser_identifier = "#{browser_hash["os"]}-#{browser_hash["browser"]}-#{browser_hash["browser-version"]}"
  FileUtils.mkdir_p(File.dirname(__FILE__) + "/report/" + browser_identifier)

  png = page.capture_screenshot_to_string
  File.open(File.dirname(__FILE__) + "/report/" + browser_identifier + "/%03i-%s-screenshot.png" % [@@steps[browser_identifier]+=1, page_name], 'wb') do |f|
    f.write(Base64.decode64(png))
    f.close
  end
end
