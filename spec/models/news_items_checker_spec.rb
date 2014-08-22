require 'spec_helper'

describe NewsItemsChecker do
  describe '.perform' do
    let(:rss_feed_url) { mock_model(RssFeedUrl, url: 'http://www.example.com/rss/1.xml') }
    let(:news_item_with_404_link) { mock_model(NewsItem, link: 'http://www.example.com/page2') }
    let(:links) { %w(http://www.example.com/page1 http://www.example.com/page2) }
    let(:news_items) do
      [mock_model(NewsItem, link: 'http://www.example.com/page1'), news_item_with_404_link]
    end
    let(:bad_news_items) { mock('bad news items') }

    it 'destroy NewsItem with link that returns HTTP status 404' do
      NewsItem.stub_chain(:where, :find_in_batches).and_yield(news_items)

      UrlStatusCodeFetcher.should_receive(:fetch) do |args|
        links.each { |link| args.should include(link) }
      end.and_yield('http://www.example.com/page1', '200 OK').
        and_yield(news_item_with_404_link.link, '404 Not Found')


      NewsItem.should_receive(:where).
        with(rss_feed_url_id: rss_feed_url.id,
             link: [news_item_with_404_link.link]).
        and_return(bad_news_items)

      bad_news_items.should_receive(:pluck).with(:id).and_return([news_item_with_404_link.id])

      RssFeedUrl.should_receive(:find_by_id).and_return(rss_feed_url)
      NewsItem.should_receive(:fast_delete).with([news_item_with_404_link.id])

      NewsItemsChecker.perform [rss_feed_url.id]
    end
  end
end
