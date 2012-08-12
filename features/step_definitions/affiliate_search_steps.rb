Given /^affiliate "([^\"]*)" has the following RSS feeds:$/ do |affiliate_name, table|
  affiliate = Affiliate.find_by_name affiliate_name
  table.hashes.each do |hash|
    shown_in_govbox = hash[:shown_in_govbox].blank? ? true : hash[:shown_in_govbox]
    rss_feed = affiliate.rss_feeds.new(:name => hash[:name],
                                       :shown_in_govbox => shown_in_govbox)
    rss_feed.rss_feed_urls.build(:url => hash[:url],
                                 :last_crawled_at => hash[:last_crawled_at],
                                 :last_crawl_status => hash[:last_crawl_status] || RssFeedUrl::PENDING_STATUS)
    rss_feed.save!
    rss_feed.navigation.update_attributes!(:is_active => hash[:is_navigable] || false,
                                           :position => hash[:position] || 100)
  end
  NewsItem.destroy_all
end

Given /^feed "([^\"]*)" has the following news items:$/ do |feed_name, table|
  rss_feed = RssFeed.find_by_name feed_name
  rss_feed_url = rss_feed.rss_feed_urls.first
  table.hashes.each do |hash|
    published_at = hash["published_ago"].blank? ? 1.day.ago : 1.send(hash["published_ago"]).ago
    rss_feed_url.news_items.create!(:rss_feed => rss_feed,
                                    :link => hash["link"],
                                    :title => hash["title"],
                                    :description => hash["description"],
                                    :guid => hash["guid"],
                                    :published_at => published_at,
                                    :contributor => hash["contributor"],
                                    :publisher => hash["publisher"],
                                    :subject => hash["subject"])
  end
  Sunspot.commit
end

Given /^there are (\d+)( video)? news items for "([^\"]*)"$/ do |count, is_video, feed_name|
  rss_feed = RssFeed.find_by_name feed_name
  rss_feed_url = rss_feed.rss_feed_urls.first
  now = Time.current.to_i
  published_at = 1.week.ago
  count.to_i.times do |index|
    link_param = is_video ? {:v => "#{index}"} : {}
    rss_feed_url.news_items.create!(:rss_feed => rss_feed,
                                    :link => "http://aff.gov/#{now}_#{index + 1}?#{link_param.to_query}",
                                    :title => "news item #{index + 1} title for #{feed_name}",
                                    :description => "news item #{index + 1} description for #{feed_name}",
                                    :guid => "#{now}_#{index + 1}",
                                    :published_at => published_at - index)
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

When /^(.*)\'s agency govbox is disabled$/ do |affiliate_name|
  Affiliate.find_by_name(affiliate_name).update_attributes(:is_agency_govbox_enabled => false)
end

Given /^the following Medline Topics exist:$/ do |table|
  table.hashes.each do |hash|
    MedTopic.create!(:medline_title => hash['medline_title'], :medline_tid => hash['medline_tid'].to_i, :locale => hash['locale'], :summary_html => hash['summary_html'])
  end
end

Given /^the following Related Medline Topics for "([^\"]*)" in (English|Spanish) exist:$/ do |medline_title, language, table|
  locale = language == 'English' ? 'en' : 'es'
  topic = MedTopic.where(:medline_title => medline_title, :locale => locale).first
  table.hashes.each do |hash|
    topic.med_related_topics.create!(:related_medline_tid => hash[:medline_tid],
                                     :title => hash[:medline_title],
                                     :url => hash[:url])
  end
end

Then /^I should see (\d+) youtube thumbnails?$/ do |count|
  page.should have_selector("img[src^='http://i.ytimg.com/vi/']", :count => count)
end

Then /^I should see youtube thumbnail for "([^\"]*)"$/ do |news_item_title|
  news_item = NewsItem.find_by_title(news_item_title)
  video_id = CGI.parse(URI.parse(news_item.link).query)['v']
  page.should have_selector("img[src='http://i.ytimg.com/vi/#{video_id}/2.jpg']")
end

Then /^I should see (.+)\'s date in the (English|Spanish) search results$/ do |duration, locale|
  date = Date.current.send(duration.to_sym)
  date_string = locale == 'Spanish' ? date.strftime("%d/%m/%Y") : date.strftime("%m/%d/%Y")
  page.should have_content(date_string)
end

Then /^I should see (\d+) news results?$/ do |count|
  page.should have_selector(".newsitem", :count => count)
end

Then /^I should see (\d+) video news results$/ do |count|
  page.should have_selector(".newsitem.video", :count => count)
end

Given /^the following Twitter Profiles exist:$/ do |table|
  table.hashes.each do |hash|
    affiliate = Affiliate.find_by_name(hash[:affiliate])
    affiliate.twitter_profiles.destroy_all
    affiliate.twitter_profiles.create!(:screen_name => hash[:screen_name],
                                       :name => hash[:name] || hash[:screen_name],
                                       :twitter_id => hash[:twitter_id],
                                       :profile_image_url => 'http://a0.twimg.com/profile_images/1879738641/USASearch_avatar_normal.png')
  end
end

Given /^the following Tweets exist:$/ do |table|
  table.hashes.each do |hash|
    Tweet.create!(:tweet_text => hash[:tweet_text], :tweet_id => hash[:tweet_id], :published_at => Time.parse(hash[:published_at]), :twitter_profile_id => hash[:twitter_profile_id])
  end
  Tweet.reindex
end

Given /^the following FlickrPhotos exist:$/ do |table|
  table.hashes.each do |hash|
    affiliate = Affiliate.find_by_name(hash[:affiliate_name])
    affiliate.flickr_profiles.find_or_create_by_url_and_profile_type_and_profile_id("http://flickr.com/photos/USagency", 'user', '1234')
    flickr_photo = FlickrPhoto.create!(:title => hash[:title], :description => hash[:description], :url_sq => hash[:url_sq], :url_q => hash[:url_q], :owner => hash[:owner], :flickr_id => hash[:flickr_id], :flickr_profile => affiliate.flickr_profiles.first)
    flickr_photo.update_attributes(:date_taken => Date.parse(hash[:date_taken])) unless hash[:date_taken].blank?
  end
  FlickrPhoto.reindex
end

Then /^I should see (\d+) collapsible facet values?$/ do |count|
  page.should have_selector('.collapsible', :count => count)
end

Then /^I should not see collapsible facet value$/ do
  page.should_not have_selector('.collapsible')
end
