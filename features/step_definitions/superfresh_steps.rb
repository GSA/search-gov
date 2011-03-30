When /^the MSNbot visits the superfresh feed$/ do
  page.driver.header "User-Agent", SuperfreshUrl::MSNBOT_USER_AGENT
  visit main_superfresh_feed_path
end

Given /^the following SuperfreshUrls exist:$/ do |table|
  table.hashes.each do |hash|
    SuperfreshUrl.create(:url => hash["url"], :affiliate => Affiliate.find_by_name(hash["affiliate"]))
  end
end

