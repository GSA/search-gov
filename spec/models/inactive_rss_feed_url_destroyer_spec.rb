require 'spec_helper'

describe InactiveRssFeedUrlDestroyer do

  it_behaves_like 'a ResqueJobStats job'

  describe '.perform' do
    let(:rss_feed_url) { mock_model(RssFeedUrl) }

    context 'when RssFeeds are not present' do
      it 'destroys the RssFeedUrl' do
        expect(RssFeedUrl).to receive(:find_by_id).with(100).and_return(rss_feed_url)
        expect(rss_feed_url).to receive(:rss_feeds).and_return([])
        expect(rss_feed_url).to receive(:destroy)

        InactiveRssFeedUrlDestroyer.perform 100
      end
    end
  end
end
