Given /^affiliate "([^"]*)" has the following RSS feeds:$/ do |affiliate_name, table|
  affiliate = Affiliate.find_by_name affiliate_name
  table.hashes.each do |hash|
    is_navigable = hash["is_navigable"].blank? ? true : hash["is_navigable"]
    RssFeed.create!(:name => hash["name"], :url => hash["url"], :is_navigable => is_navigable, :affiliate => affiliate)
  end
  NewsItem.destroy_all
end

Given /^feed "([^"]*)" has the following news items:$/ do |feed_name, table|
  rss_feed = RssFeed.find_by_name feed_name
  table.hashes.each do |hash|
    published_at = hash["published_ago"].blank? ? 1.day.ago : 1.send(hash["published_ago"]).ago
    NewsItem.create!(:link => hash["link"], :title => hash["title"], :description => hash["description"],
                     :guid => hash["guid"], :published_at => published_at, :rss_feed => rss_feed)
  end
  Sunspot.commit
end

Then /^I should not see "([^\"]*)" in bold font$/ do |text|
  page.should_not have_selector("strong", :text => text)
end

Then /^I should see "([^\"]*)" in bold font$/ do |text|
  page.should have_selector("strong", :text => text)
end

Then /^I should not see the indexed documents section$/ do
  page.should_not have_selector("#indexed_documents")
end

Then /^I should see the agency govbox$/ do
  page.should have_selector(".agency")
end

Then /^I should see agency govbox deep links$/ do
  page.should have_selector(".agency .deep-links")
end

When /^(.*)'s agency govbox is disabled$/ do |affiliate_name|
  Affiliate.find_by_name(affiliate_name).update_attributes(:is_agency_govbox_enabled => false)
end

Given /^the following Medline Topics exist:$/ do |table|
  table.hashes.each do |hash|
    MedTopic.create!(:medline_title => hash['medline_title'], :medline_tid => hash['medline_tid'].to_i, :locale => hash['locale'], :summary_html => hash['summary_html'])
  end
end

Given /^the following Related Medline Topics for "([^"]*)" in (English|Spanish) exist:$/ do |medline_title, language, table|
  locale = language == 'English' ? 'en' : 'es'
  topic = MedTopic.where(:medline_title => medline_title, :locale => locale).first
  table.hashes.each do |hash|
    related_topic = MedTopic.create!(:medline_title => hash[:medline_title], :medline_tid => hash[:medline_tid], :locale => locale)
    topic.topic_relatees.create!(:related_topic => related_topic)
  end
end

Then /^I should see (\d+) youtube thumbnails?$/ do |count|
  page.should have_selector("img[src^='http://i.ytimg.com/vi/']", :count => count)
end

Then /^I should see youtube thumbnail for "([^"]*)"$/ do |news_item_title|
  news_item = NewsItem.find_by_title(news_item_title)
  video_id = CGI.parse(URI.parse(news_item.link).query)['v']
  page.should have_selector("img[src='http://i.ytimg.com/vi/#{video_id}/2.jpg']")
end

Then /^I should see (.+)'s date in the (English|Spanish) search results$/ do |duration, locale|
  date = Date.current.send(duration.to_sym)
  date_string = locale == 'Spanish' ? date.strftime("%d/%m/%Y") : date.strftime("%m/%d/%Y")
  page.should have_content(date_string)
end
