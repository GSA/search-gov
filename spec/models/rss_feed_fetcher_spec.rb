require 'spec_helper'

describe RssFeedFetcher do
  describe '.perform' do
    it 'should import the RssFeedUrl' do
      rss_feed_url = mock_model RssFeedUrl
      RssFeedUrl.should_receive(:find_by_id).with(100).and_return rss_feed_url
      rss_feed_data = mock(RssFeedData)
      RssFeedData.should_receive(:new).with(rss_feed_url, true).and_return rss_feed_data
      rss_feed_data.should_receive :import
      RssFeedFetcher.perform(100)
    end
  end
end
