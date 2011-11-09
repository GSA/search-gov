Given /^affiliate "([^"]*)" has the following RSS feeds:$/ do |affiliate_name, table|
  affiliate = Affiliate.find_by_name affiliate_name
  table.hashes.each do |hash|
    RssFeed.create!(:name => hash["name"], :url => hash["url"], :is_active => hash["is_active"], :affiliate => affiliate)
  end
  NewsItem.delete_all
end

Given /^feed "([^"]*)" has the following news items:$/ do |feed_name, table|
  rss_feed = RssFeed.find_by_name feed_name
  table.hashes.each do |hash|
    NewsItem.create!(:link => hash["link"], :title => hash["title"], :description => hash["description"],
                     :guid => hash["guid"], :published_at => 1.send(hash["published_ago"]).ago, :rss_feed => rss_feed)
  end
  Sunspot.commit
end

Then /^I should not see "([^\"]*)" in bold font$/ do |text|
  page.should_not have_selector("strong", :text => text)
end

Then /^I should see "([^\"]*)" in bold font$/ do |text|
  page.should have_selector("strong", :text => text)
end

