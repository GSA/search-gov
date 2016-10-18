require 'spec_helper'

describe SiteFeedUrlFetcher do
  describe '.perform' do
    it 'should import the SiteFeedUrl' do
      site_feed_url = mock_model SiteFeedUrl
      SiteFeedUrl.should_receive(:find_by_id).with(100).and_return site_feed_url

      site_feed_url_data = double(SiteFeedUrlData)
      SiteFeedUrlData.should_receive(:new).with(site_feed_url).and_return(site_feed_url_data)
      site_feed_url_data.should_receive :import
      SiteFeedUrlFetcher.perform(100)
    end
  end
end
