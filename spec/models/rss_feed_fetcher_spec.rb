require 'spec_helper'

describe RssFeedFetcher do
  it_behaves_like 'a ResqueJobStats job'

  describe '.perform' do
    it 'should import the RssFeedUrl' do
      rss_feed_url = mock_model RssFeedUrl
      expect(RssFeedUrl).to receive(:find_by_id).with(100).and_return rss_feed_url
      rss_feed_data = double(RssFeedData)
      expect(RssFeedData).to receive(:new).with(rss_feed_url, true).and_return rss_feed_data
      expect(rss_feed_data).to receive :import
      RssFeedFetcher.perform(100)
    end
  end

  describe "enqueueing" do
    it 'should not enqueue two RssFeedFetcher jobs with the same args' do
      expect(Resque.enqueue(RssFeedFetcher, 31415, false)).to be true
      expect(Resque.enqueue(RssFeedFetcher, 31415, false)).to be_nil
    end
  end
end
