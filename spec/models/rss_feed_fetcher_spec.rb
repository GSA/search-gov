# frozen_string_literal: true

describe RssFeedFetcher do
  it_behaves_like 'a ResqueJobStats job'

  describe '.perform' do
    it 'imports the RssFeedUrl' do
      rss_feed_url = mock_model RssFeedUrl
      expect(RssFeedUrl).to receive(:find_by_id).with(100).and_return rss_feed_url
      rss_feed_data = double(RssFeedData)
      expect(RssFeedData).to receive(:new).with(rss_feed_url, true).and_return rss_feed_data
      expect(rss_feed_data).to receive :import
      described_class.perform(100)
    end
  end

  describe 'enqueueing' do
    before do
      # remove any locks leftover from previous spec runs
      Resque.redis.del('loner:lock:RssFeedFetcher:31415-false')
    end

    it 'does not enqueue two RssFeedFetcher jobs with the same args' do
      expect(Resque.enqueue(described_class, 31_415, false)).to be true
      expect(Resque.enqueue(described_class, 31_415, false)).to be_nil
    end
  end
end
