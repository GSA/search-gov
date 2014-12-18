shared_examples 'a commercial API search as_json' do
  context 'when news items are present' do
    let(:current_time) { DateTime.parse 'Wed, 17 Dec 2014 18:33:43 +0000' }

    before do
      rss_feed = search.affiliate.rss_feeds.build(name: 'News')
      url = 'http://search.digitalgov.gov/all.atom'
      rss_feed_url = RssFeedUrl.rss_feed_owned_by_affiliate.build(url: url)
      rss_feed_url.save!(validate: false)
      rss_feed.rss_feed_urls = [rss_feed_url]
      rss_feed.save!

      news_items = (1..2).map do |i|
        attributes = {
          title: "recent news title-#{i}",
          link: "http://search.digitalgov.gov/news-#{i}",
          guid: "blog-#{i}",
          description: "v2 news description #{i}",
          published_at: current_time.advance(days: -i)
        }
        rss_feed_url.news_items.create! attributes
      end

      search.stub(:news_items) { mock(ElasticNewsItemResults, results: news_items) }
    end

    it 'includes recent_news' do
      search_rash = Hashie::Rash.new(JSON.parse(search.to_json, symbolize_names: true))
      recent_news_item = search_rash.recent_news.first.to_hash.symbolize_keys
      expect(recent_news_item).to eq(pub_date: '2014-12-16',
                                     source: 'News',
                                     title: 'recent news title-1',
                                     url: 'http://search.digitalgov.gov/news-1')

      recent_news_item = search_rash.recent_news.last.to_hash.symbolize_keys
      expect(recent_news_item).to eq(pub_date: '2014-12-15',
                                     source: 'News',
                                     title: 'recent news title-2',
                                     url: 'http://search.digitalgov.gov/news-2')
    end
  end
end
