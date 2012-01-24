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

Then /^I should not see the indexed documents section$/ do
  page.should_not have_selector("#indexed_documents")
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
