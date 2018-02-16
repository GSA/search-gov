require 'spec_helper'

describe SiteFeedUrlFetcher do
  it_behaves_like 'a ResqueJobStats job'

  describe '.perform' do
    it 'should import the SiteFeedUrl' do
      site_feed_url = mock_model SiteFeedUrl
      expect(SiteFeedUrl).to receive(:find_by_id).with(100).and_return site_feed_url

      site_feed_url_data = double(SiteFeedUrlData)
      expect(SiteFeedUrlData).to receive(:new).with(site_feed_url).and_return(site_feed_url_data)
      expect(site_feed_url_data).to receive :import
      SiteFeedUrlFetcher.perform(100)
    end
  end

  describe '.before_perform_with_timeout' do
    before { @original_timeout = Resque::Plugins::Timeout.timeout }
    after { Resque::Plugins::Timeout.timeout = @original_timeout }

    it 'sets Resque::Plugins::Timeout.timeout to 20 minutes' do
      described_class.before_perform_with_timeout
      expect(Resque::Plugins::Timeout.timeout).to eq(20.minutes)
    end
  end
end
