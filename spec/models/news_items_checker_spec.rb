require 'spec_helper'

describe NewsItemsChecker do
  describe '.perform' do
    let(:news_item_bad_url) { mock_model(NewsItem, link: 'http://www.example.com/page2') }
    let(:links) { %w(http://www.example.com/page1 http://www.example.com/page2) }
    let(:news_items) do
      [mock_model(NewsItem, link: 'http://www.example.com/page1'), news_item_bad_url]
    end

    it 'destroy NewsItem with link that returns HTTP status 404' do
      NewsItem.stub_chain(:where, :find_in_batches).and_yield(news_items)

      UrlStatusCodeFetcher.should_receive(:fetch) do |args|
        links.each { |link| args.should include(link) }
      end.and_yield('http://www.example.com/page1', '200 OK').
          and_yield('http://www.example.com/page4', '404 Not Found')

      NewsItem.should_receive(:find_by_rss_feed_url_id_and_link).
          with(100, 'http://www.example.com/page4').
          and_return(news_item_bad_url)
      news_item_bad_url.should_receive(:pluck).with(:id).and_return(999)
      NewsItem.should_receive(:fast_delete).with([999])

      NewsItemsChecker.perform [100], 1, 999
    end
  end
end
