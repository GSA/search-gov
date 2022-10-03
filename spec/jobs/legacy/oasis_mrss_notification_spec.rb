require 'spec_helper'

describe OasisMrssNotification, '.perform' do
  fixtures :rss_feed_urls
  let(:media_feed_url) { rss_feed_urls(:media_feed_url) }

  it_behaves_like 'a ResqueJobStats job'

  context 'when feed looks like a photo feed' do
    before do
      allow(HttpConnection).to receive(:get).and_return Rails.root.join('spec/fixtures/rss/media_rss_with_media_content_type.xml').read
      response_json = { 'id' => 'http://some.mrss.url/feed2.xml', 'name' => '123' }.as_json
      allow(Oasis).to receive(:subscribe_to_mrss).and_return response_json
    end

    it 'should link the oasis_mrss_name to an Oasis MRSS profile' do
      described_class.perform(media_feed_url.id)
      expect(RssFeedUrl.find(media_feed_url.id).oasis_mrss_name).to eq('123')
    end
  end

  context 'when feed URL looks like it is not an image feed' do
    ['http://gdata.youtube.com/feeds/base/playlists/PLrl7E8KABz1FGAcIK3vO8xj_nYfAlzhMX?alt=rss',
     'http://www.jbsa.af.mil/shared/xml/rssVideo.asp?mrsstype=1&cid=661',
     'http://grants.nih.gov/podcasts/All_About_Grants/AAG_Feed.xml',
     'http://www.fema.gov/media-library/assets/audio/rss.xml',
     'http://www.fema.gov/media-library/assets/vodcast/rss.xml',
     'http://cdn-api.ooyala.com/syndication/mp4?id=9bf43e6b-2172-404f-b326-076b1d1c7389',
     'https://api.flickr.com/services/feeds/photos_public.gne?id=47838549@N08&lang=en-us&format=rss_200'].each do |url|

      it 'should not subscribe to Oasis' do
        allow(RssFeedUrl).to receive(:find).and_return double(RssFeedUrl, url: url)
        expect(described_class.perform(url)).to eq('URL does not look like an image URL')
      end
    end
  end

  context 'when XML root is not RSS' do
    before do
      allow(HttpConnection).to receive(:get).and_return Rails.root.join('spec/fixtures/rss/atom_feed.xml').read
    end

    it 'should not subscribe to Oasis' do
      expect(described_class.perform(rss_feed_urls(:atom_feed_url).id)).to eq('XML root is not RSS')
    end
  end

  context 'when namespaces does not contain MRSS' do
    before do
      allow(HttpConnection).to receive(:get).and_return Rails.root.join('spec/fixtures/rss/site_feed.xml').read
    end

    it 'should not subscribe to Oasis' do
      expect(described_class.perform(rss_feed_urls(:another_url).id)).to eq('Missing MRSS namespace')
    end
  end

  context 'when MRSS feed is missing thumbnails' do
    before do
      allow(HttpConnection).to receive(:get).and_return Rails.root.join('spec/fixtures/rss/missing_thumbnails.xml').read
    end

    it 'should not subscribe to Oasis' do
      expect(described_class.perform(rss_feed_urls(:another_url).id)).to eq('Missing media thumbnails')
    end
  end

  context 'when something goes wrong' do
    before do
      allow(HttpConnection).to receive(:get).and_raise Exception
    end

    it 'should log warning' do
      expect(Rails.logger).to receive(:warn)
      described_class.perform(rss_feed_urls(:another_url).id)
    end
  end
end
