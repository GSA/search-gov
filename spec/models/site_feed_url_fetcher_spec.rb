require 'spec_helper'

describe SiteFeedUrlFetcher do
  describe '.perform' do
    it 'should import the SiteFeedUrl' do
      site_feed_url = mock_model SiteFeedUrl
      SiteFeedUrl.should_receive(:find_by_id).with(100).and_return site_feed_url
      site_feed_url.should_receive :fetch
      SiteFeedUrlFetcher.perform(100)
    end
  end
end
