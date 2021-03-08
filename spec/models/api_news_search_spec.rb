require 'spec_helper'

describe ApiNewsSearch do
  fixtures :affiliates, :rss_feed_urls, :rss_feeds, :navigations, :news_items, :youtube_profiles

  describe '#initialize(options)' do
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:managed_feed) { affiliate.rss_feeds.managed.first }

    before(:all) do
      NewsItem.all.each { |news_item| news_item.save! }
      ElasticNewsItem.commit
    end

    context 'when channel is not specified' do
      let(:search) { described_class.new affiliate: affiliate, query: 'element' }
      let(:non_managed_and_navigable_only_feeds) { affiliate.rss_feeds.non_managed.navigable_only.to_a }

      it 'searches on non managed navigable only rss feeds' do
        expect(ElasticNewsItem).to receive(:search_for).
            with(q: 'element',
                 rss_feeds: non_managed_and_navigable_only_feeds,
                 excluded_urls: affiliate.excluded_urls,
                 since: nil,
                 until: nil,
                 size: 10,
                 offset: 0,
                 contributor: nil, subject: nil, publisher: nil,
                 sort: 'published_at:desc',
                 tags: [],
                 language: 'en')
        search.run
      end
    end

    context 'when channel is referring to a managed feed' do
      subject do
        described_class.new affiliate: affiliate,
                          channel: managed_feed.id.to_s,
                          query: 'element'
      end

      before do
        expect(ElasticNewsItem).not_to receive :search_for
        subject.run
      end

      its(:rss_feed) { should be_nil }
    end
  end
end
