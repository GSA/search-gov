require 'spec_helper'

describe OasisMrssNotification, ".perform" do
  fixtures :rss_feed_urls
  let(:media_feed_url) { rss_feed_urls(:media_feed_url) }
  context 'when feed looks like a photo feed' do
    before do
      HttpConnection.stub(:get).and_return Rails.root.join('spec/fixtures/rss/media_rss_with_media_content_type.xml').read
      response_json = { 'id' => 'http://some.mrss.url/feed2.xml', 'name' => "123" }.as_json
      Oasis.stub(:subscribe_to_mrss).and_return response_json
    end

    it 'should link the oasis_mrss_name to an Oasis MRSS profile' do
      OasisMrssNotification.perform(media_feed_url.id)
      RssFeedUrl.find(media_feed_url.id).oasis_mrss_name.should == '123'
    end
  end

  context 'when feed URL looks like it is not an image feed' do
    ["http://gdata.youtube.com/feeds/base/playlists/PLrl7E8KABz1FGAcIK3vO8xj_nYfAlzhMX?alt=rss",
     "http://www.jbsa.af.mil/shared/xml/rssVideo.asp?mrsstype=1&cid=661",
     "http://grants.nih.gov/podcasts/All_About_Grants/AAG_Feed.xml",
     "http://www.fema.gov/media-library/assets/audio/rss.xml",
     "http://www.fema.gov/media-library/assets/vodcast/rss.xml",
     "https://api.flickr.com/services/feeds/photos_public.gne?id=47838549@N08&lang=en-us&format=rss_200"].each do |url|

      it 'should not subscribe to Oasis' do
        RssFeedUrl.stub(:find).and_return double(RssFeedUrl, url: url)
        OasisMrssNotification.perform(url).should == "URL does not look like an image URL"
      end
    end
  end

  context 'when XML root is not RSS' do
    before do
      HttpConnection.stub(:get).and_return Rails.root.join('spec/fixtures/rss/atom_feed.xml').read
    end

    it 'should not subscribe to Oasis' do
      OasisMrssNotification.perform(rss_feed_urls(:atom_feed_url)).should == "XML root is not RSS"
    end
  end

  context 'when namespaces does not contain MRSS' do
    before do
      HttpConnection.stub(:get).and_return Rails.root.join('spec/fixtures/rss/site_feed.xml').read
    end

    it 'should not subscribe to Oasis' do
      OasisMrssNotification.perform(rss_feed_urls(:another_url)).should == "Missing MRSS namespace"
    end
  end

  context 'when MRSS feed is missing thumbnails' do
    before do
      HttpConnection.stub(:get).and_return Rails.root.join('spec/fixtures/rss/missing_thumbnails.xml').read
    end

    it 'should not subscribe to Oasis' do
      OasisMrssNotification.perform(rss_feed_urls(:another_url)).should == "Missing media thumbnails"
    end
  end
end