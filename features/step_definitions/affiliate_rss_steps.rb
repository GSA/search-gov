=begin
Given /^the following RSS feeds exist:$/ do |table|
  table.hashes.each do |hash|
    RssFeed.create!(:affiliate => Affiliate.find_by_name(hash['affiliate']), :url => hash['url'], :name => hash['name'], :is_navigable => true)
  end
end
=end

Given /^the following News Items exist:$/ do |table|
  table.hashes.each do |hash|
    NewsItem.create!(:title => hash['title'], :guid => hash['guid'], :link => hash['link'], :description => hash['description'], :rss_feed => RssFeed.find_by_name(hash['feed_name']), :published_at => Time.now)
  end
  Sunspot.commit
end
