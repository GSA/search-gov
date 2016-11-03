require 'spec_helper'

describe RssFeedFetcher do
  describe '.perform' do
    it 'should import the RssFeedUrl' do
      rss_feed_url = mock_model RssFeedUrl
      RssFeedUrl.should_receive(:find_by_id).with(100).and_return rss_feed_url
      rss_feed_data = double(RssFeedData)
      RssFeedData.should_receive(:new).with(rss_feed_url, true).and_return rss_feed_data
      rss_feed_data.should_receive :import
      RssFeedFetcher.perform(100)
    end

    it 'should timeout if it runs too long' do
      Resque::Plugins::Timeout.timeout.should == 599
    end
  end

  describe "enqueueing" do
    it 'should not enqueue two RssFeedFetcher jobs with the same args' do
      Resque.enqueue(RssFeedFetcher, 31415, false).should be true
      Resque.enqueue(RssFeedFetcher, 31415, false).should be_nil
    end
  end
end
