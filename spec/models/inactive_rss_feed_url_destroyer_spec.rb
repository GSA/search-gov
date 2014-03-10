require 'spec_helper'

describe InactiveRssFeedUrlDestroyer do
  describe '.perform' do
    let(:rss_feed_url) { mock_model(RssFeedUrl) }

    context 'when RssFeeds are not present' do
      it 'destroys the RssFeedUrl' do
        RssFeedUrl.should_receive(:find_by_id).with(100).and_return(rss_feed_url)
        rss_feed_url.should_receive(:rss_feeds).and_return([])
        rss_feed_url.should_receive(:destroy)

        InactiveRssFeedUrlDestroyer.perform 100
      end
    end
  end
end
