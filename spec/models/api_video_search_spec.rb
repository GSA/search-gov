# frozen_string_literal: true

describe ApiVideoSearch do
  let(:affiliate) { affiliates(:usagov_affiliate) }

  describe '#search' do
    context 'when the site does not have youtube profiles' do
      before { expect(affiliate).to receive(:youtube_profile_ids).and_return([]) }

      it 'returns nil' do
        search = described_class.new(affiliate: affiliate, query: 'my video')
        expect(search.search).to be_nil
      end
    end
  end

  describe '#run' do
    context 'when the site has youtube_profiles' do
      let(:youtube_profile_rss_feeds) { double('YoutubeProfile RssFeeds') }
      let(:search_options) do
        { affiliate: affiliate,
          enable_highlighting: false,
          offset: 23,
          pre_tags: ["\ue000"],
          post_tags: ["\ue001"],
          query: 'my video',
          limit: 8 }
      end

      before do
        expect(RssFeed).to receive(:youtube_profile_rss_feeds_by_site).
          with(affiliate).
          and_return(youtube_profile_rss_feeds)
      end

      it 'executes ElasticNewsItem.search_for' do
        expect(ElasticNewsItem).to receive(:search_for).
          with({ highlighting: false,
                 language: 'en',
                 offset: 23,
                 pre_tags: ["\ue000"],
                 post_tags: ["\ue001"],
                 q: 'my video',
                 rss_feeds: youtube_profile_rss_feeds,
                 size: 8,
                 sort_by_relevance: true })

        described_class.new(search_options).run
      end

      it 'handles response' do
        results = [double('result 1')]
        response = double('response', results: results, total: 100)
        expect(ElasticNewsItem).to receive(:search_for).and_return(response)
        search = described_class.new(
          search_options.merge(next_offset_within_limit: true)
        )
        search.run

        expect(search.results).to eq(results)
        expect(search.total).to eq(100)
        expect(search.next_offset).to eq(31)
        expect(search.modules).to eq(%w[VIDS])
      end

      context 'when sort_by=date' do
        it 'executes ElasticNewsItem.search_for with sort_by_relevance=false' do
          expect(ElasticNewsItem).to receive(:search_for).
            with({ highlighting: false,
                   language: 'en',
                   offset: 23,
                   pre_tags: ["\ue000"],
                   post_tags: ["\ue001"],
                   q: 'my video',
                   rss_feeds: youtube_profile_rss_feeds,
                   size: 8,
                   sort_by_relevance: false })

          described_class.new(search_options.merge(sort_by: 'date')).run
        end
      end
    end
  end

  describe '#as_json' do
    fixtures :rss_feed_urls, :rss_feeds, :youtube_profiles

    let(:current_time) { DateTime.parse 'Wed, 17 Dec 2014 18:33:43 +0000' }

    let(:search) do
      described_class.new(affiliate: affiliate,
                          limit: 2,
                          next_offset_within_limit: true,
                          offset: 23,
                          query: 'my video')
    end

    before do
      youtube_profile = youtube_profiles(:whitehouse)
      search.affiliate.enable_video_govbox!

      rss_feed_url = youtube_profile.rss_feed.rss_feed_urls.first
      rss_feed_url.news_items.delete_all

      news_items = (1..2).map do |i|
        NewsItem.create!(rss_feed_url: rss_feed_url,
                         link: "http://www.youtube.com/watch?v=#{i}&feature=youtube_gdata",
                         title: "video #{i}",
                         description: "video news description #{i}",
                         published_at: current_time.advance(days: -i),
                         guid: "http://gdata.youtube.com/feeds/base/videos/#{i}",
                         duration: "#{i}:0#{i}",
                         updated_at: Time.current)
      end

      elastic_results = double(ElasticNewsItemResults,
                               results: news_items,
                               total: 30)

      expect(ElasticNewsItem).to receive(:search_for).and_return(elastic_results)
    end

    it 'renders YouTube news items' do
      search.run

      video = Hashie::Mash::Rash.new(JSON.parse(search.to_json)).video
      expect(video.total).to eq(30)
      expect(video.next_offset).to eq(25)

      news_item = video.results.first.to_hash.symbolize_keys
      expect(news_item).to eq(publication_date: '2014-12-16',
                              snippet: 'video news description 1',
                              source: 'YouTube',
                              thumbnail_url: 'https://i.ytimg.com/vi/1/default.jpg',
                              duration: '1:01',
                              title: 'video 1',
                              url: 'http://www.youtube.com/watch?v=1&feature=youtube_gdata')

      news_item = video.results.last.to_hash.symbolize_keys
      expect(news_item).to eq(publication_date: '2014-12-15',
                              snippet: 'video news description 2',
                              source: 'YouTube',
                              thumbnail_url: 'https://i.ytimg.com/vi/2/default.jpg',
                              duration: '2:02',
                              title: 'video 2',
                              url: 'http://www.youtube.com/watch?v=2&feature=youtube_gdata')
    end
  end
end
