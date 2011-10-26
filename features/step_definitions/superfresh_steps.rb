When /^the MSNbot visits the superfresh feed$/ do
  page.driver.header "User-Agent", SuperfreshUrl::MSNBOT_USER_AGENT
  visit main_superfresh_feed_path
end

Given /^the following SuperfreshUrls exist:$/ do |table|
  table.hashes.each do |hash|
    SuperfreshUrl.create(:url => hash["url"], :affiliate => Affiliate.find_by_name(hash["affiliate"]))
  end
end

Given /^the following IndexedDocuments exist:$/ do |table|
  table.hashes.each do |hash|
    IndexedDocument.create(:url => hash["url"], :affiliate => Affiliate.find_by_name(hash["affiliate"]))
  end
end

When /^the url "([^\"]*)" has been crawled$/ do |url|
  IndexedDocument.find_by_url(url).update_attributes(:last_crawled_at => Time.now, :last_crawl_status => "OK")
end
