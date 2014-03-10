require 'spec_helper'

describe NewsItemsChecker do
  describe '.perform' do
    let(:news_item_bad_url) { mock_model(NewsItem, link: 'http://www.example.com/page2') }
    let(:batch_group) do
      [mock_model(NewsItem, link: 'http://www.example.com/page1'), news_item_bad_url]
    end

    it 'destroy NewsItem with link that returns HTTP status 404' do
      NewsItem.stub_chain(:where, :select, :find_in_batches).and_yield(batch_group)
      UrlStatusCodeFetcher.should_receive(:fetch).
          and_yield('http://www.example.com/page1', '200 OK').
          and_yield('http://www.example.com/page4', '404 Not Found')
      NewsItem.should_receive(:find_by_rss_feed_url_id_and_link).
          with(100, 'http://www.example.com/page4').
      and_return(news_item_bad_url)
      news_item_bad_url.should_receive(:destroy)

      NewsItemsChecker.perform 100
    end
  end
end
