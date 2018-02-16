require 'spec_helper'

describe NewsItemsChecker do
  it_behaves_like 'a ResqueJobStats job'

  describe '.perform' do
    let(:rss_feed_url) { mock_model(RssFeedUrl, url: 'http://www.example.com/rss/1.xml') }
    let(:news_item_with_404_link) { mock_model(NewsItem, link: 'http://www.example.com/page2') }
    let(:links) { %w(http://www.example.com/page1 http://www.example.com/page2) }
    let(:news_items) do
      [mock_model(NewsItem, link: 'http://www.example.com/page1'), news_item_with_404_link]
    end
    let(:bad_news_items) { double('bad news items') }

    it 'destroy NewsItem with link that returns HTTP status 404' do
      allow(NewsItem).to receive_message_chain(:where, :find_in_batches).and_yield(news_items)

      expect(UrlStatusCodeFetcher).to receive(:fetch) { |args|
        links.each { |link| expect(args).to include(link) }
      }.and_yield('http://www.example.com/page1', '200 OK').
        and_yield(news_item_with_404_link.link, '404 Not Found')


      expect(NewsItem).to receive(:where).
        with(rss_feed_url_id: rss_feed_url.id,
             link: [news_item_with_404_link.link]).
        and_return(bad_news_items)

      expect(bad_news_items).to receive(:pluck).with(:id).and_return([news_item_with_404_link.id])

      expect(RssFeedUrl).to receive(:find_by_id).and_return(rss_feed_url)
      expect(NewsItem).to receive(:fast_delete).with([news_item_with_404_link.id])

      NewsItemsChecker.perform [rss_feed_url.id]
    end
  end
end
