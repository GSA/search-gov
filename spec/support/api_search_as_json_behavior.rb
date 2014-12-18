shared_examples 'an API search as_json' do
  context 'when tweets are present' do
    fixtures :twitter_profiles

    let(:current_time) { DateTime.current }

    before do
      search.affiliate.twitter_profiles.destroy_all
      twitter_profile = twitter_profiles(:usagov)
      affiliate.twitter_profiles << twitter_profile

      Tweet.delete_all
      tweet = Tweet.create!(
        published_at: current_time,
        tweet_id: 1234567,
        tweet_text: 'Good morning, API!',
        twitter_profile_id: twitter_profile.twitter_id)

      search.stub(:tweets) { mock(ElasticTweetResults, results: [tweet]) }
    end

    it 'includes recent_tweets' do
      search_rash = Hashie::Rash.new(JSON.parse(search.to_json))
      tweet = search_rash.recent_tweets.first.to_hash.symbolize_keys
      expect(tweet).to eq(created_at: current_time.to_time.iso8601,
                          name: 'USA.gov',
                          profile_image_url: 'http://a0.twimg.com/profile_images/1155238675/usagov_normal.jpg',
                          screen_name: 'usagov',
                          text: 'Good morning, API!',
                          url: 'https://twitter.com/usagov/status/1234567')
    end
  end

  context 'when video news items are present' do
    fixtures :rss_feed_urls, :rss_feeds, :youtube_profiles

    let(:current_time) { DateTime.parse 'Wed, 17 Dec 2014 18:33:43 +0000' }

    before do
      youtube_profile = youtube_profiles(:whitehouse)
      search.affiliate.enable_video_govbox!

      rss_feed_url = youtube_profile.rss_feed.rss_feed_urls.first
      rss_feed_url.news_items.delete_all

      news_items = (1..2).map do |i|
        NewsItem.create!(rss_feed_url: rss_feed_url,
                         link: "http://www.youtube.com/watch?v=#{i}&feature=youtube_gdata",
                         title: "video #{i}",
                         description: 'already exist description',
                         published_at: current_time.advance(days: -i),
                         guid: "http://gdata.youtube.com/feeds/base/videos/#{i}",
                         updated_at: Time.current)
      end

      search.stub(:video_news_items) { mock(ElasticNewsItemResults, results: news_items) }
    end

    it 'includes recent_news' do
      search_rash = Hashie::Rash.new(JSON.parse(search.to_json, symbolize_names: true))
      recent_news_item = search_rash.recent_video_news.first.to_hash.symbolize_keys
      expect(recent_news_item).to eq(pub_date: '2014-12-16',
                                     source: 'YouTube',
                                     thumbnail_url: 'https://i.ytimg.com/vi/1/default.jpg',
                                     title: 'video 1',
                                     url: 'http://www.youtube.com/watch?v=1&feature=youtube_gdata')

      recent_news_item = search_rash.recent_video_news.last.to_hash.symbolize_keys
      expect(recent_news_item).to eq(pub_date: '2014-12-15',
                                     source: 'YouTube',
                                     thumbnail_url: 'https://i.ytimg.com/vi/2/default.jpg',
                                     title: 'video 2',
                                     url: 'http://www.youtube.com/watch?v=2&feature=youtube_gdata')
    end
  end
end
