require 'spec_helper'

describe VideoNewsSearch do
  fixtures :affiliates

  let(:affiliate) { affiliates(:basic_affiliate) }

  describe '#initialize(options)' do
    it 'should initialize per_page' do
      expect(VideoNewsSearch.new(query: 'gov', tbs: 'w', affiliate: affiliate).per_page).to eq(20)
    end

    it 'should not overwrite per_page option' do
      expect(VideoNewsSearch.new(query: 'gov', tbs: 'w', affiliate: affiliate, per_page: '15').per_page).to eq(15)
    end
  end

  describe '#run' do
    context 'when a valid active RSS feed is specified' do
      it 'should only search for news items from that feed' do
        rss_feed = mock_model(RssFeed, is_managed?: true, show_only_media_content?: false)
        allow(affiliate).to receive_message_chain(:rss_feeds, :managed, :find_by_id).and_return(rss_feed)
        expect(affiliate).to receive(:youtube_profile_ids).twice.and_return double('youtube profile ids')
        youtube_feeds = [mock_model(RssFeed)]
        allow(RssFeed).to receive_message_chain(:includes, :owned_by_youtube_profile, :where).and_return youtube_feeds
        search = VideoNewsSearch.new(query: 'element', channel: '100', affiliate: affiliate)
        expect(ElasticNewsItem).to receive(:search_for).
          with(q: 'element', rss_feeds: youtube_feeds, excluded_urls: affiliate.excluded_urls,
               since: nil, until: nil,
               offset: 0, size: 20,
               contributor: nil, subject: nil, publisher: nil,
               sort: 'published_at:desc',
               tags: [], language: 'en')
        expect(search.run).to be true
      end
    end

    context 'when there is only 1 navigable video rss feed' do
      it 'should assign @rss_feed' do
        videos_navigable_feeds = [mock_model(RssFeed, is_managed?: true, show_only_media_content?: false)]
        allow(affiliate).to receive_message_chain(:rss_feeds, :managed, :navigable_only).and_return(videos_navigable_feeds.clone)
        expect(affiliate).to receive(:youtube_profile_ids).twice.and_return double('youtube profile ids')
        youtube_feeds = [mock_model(RssFeed)]
        allow(RssFeed).to receive_message_chain(:includes, :owned_by_youtube_profile, :where).and_return youtube_feeds
        expect(ElasticNewsItem).to receive(:search_for).
          with(q: 'element', rss_feeds: youtube_feeds, excluded_urls: affiliate.excluded_urls,
               since: Time.current.advance(weeks: -1).beginning_of_day, until: nil,
               offset: 0, size: 20,
               contributor: nil, subject: nil, publisher: nil,
               sort: 'published_at:desc',
               tags: [], language: 'en')
        search = VideoNewsSearch.new(query: 'element', tbs: 'w', affiliate: affiliate)
        search.run
        expect(search.rss_feed).to eq(videos_navigable_feeds.first)
      end
    end
  end
end
