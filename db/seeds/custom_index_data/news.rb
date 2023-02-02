# frozen_string_literal: true

# After seeding the database, you should see these news items on the SERP and News facet:
# /search?affiliate=test_affiliate&query=news
# /search/news?affiliate=test_affiliate&channel=1&query=news

affiliate = Affiliate.find_by(name: 'test_affiliate')

rss_feed = affiliate.rss_feeds.new(
  name: 'News',
  is_managed: false,
  is_video: 'false',
  owner_type: 'Affiliate',
  show_only_media_content: false
)

rss_feed.rss_feed_urls.build(
  rss_feed_owner_type: 'Affiliate',
  url: 'https://www.epa.gov/newsreleases/search/rss',
  language: 'en'
)

# enable navigation, which is created on save by navigable observer
rss_feed.save

# enable the News facet
rss_feed.navigation.update(is_active: true)

# enable the News module
affiliate.update(is_rss_govbox_enabled: true)

rss_feed_url = rss_feed.rss_feed_urls.first

(1..5).each do |i|
  rss_feed_url.news_items.create(
    link: "https://www.epa.gov/newsreleases/news_item_#{i}",
    title: "EPA News Item #{i}",
    guid: "https://www.epa.gov/newsreleases/news_item_#{i}",
    description: "This is News Item ##{i}",
    published_at: i.days.ago
  )
end
