# frozen_string_literal: true

# https://search.gov/admin-center/content/youtube.html
#
# After seeding the database, you should see this video news item on the SERP and the Video facet:
# /search?affiliate=test_affiliate&query=video
# /search/news?affiliate=test_affiliate&channel=3&query=video

puts 'Creating Youtube videos'

affiliate = Affiliate.find_by(name: 'test_affiliate')

youtube_profile = affiliate.youtube_profiles.create(
  title: 'usagovernment',
  channel_id: 'UCWjkPmmzCdPZEKtGciLf1mg',
  imported_at: Time.current
)

youtube_profile.rss_feed.rss_feed_urls.first.news_items.create(
  link: 'https://www.youtube.com/watch?v=lyusCKVyars',
  title: 'Video News Item #1',
  guid: 'lyusCKVyars',
  description:
   'This is Youtube video news item #1',
  # only videos published within the last 3 days appear in the video module
  published_at: 1.hour.ago,
  properties: { duration: '1:11' }
)

affiliate.enable_video_govbox!
