require 'spec_helper'

describe RssFeedFetcher do
  describe '.perform' do
    context 'when processing multiple RssFeeds' do
      it 'should process all of them' do
        rss_feed_ids = [100, 200]
        RssFeedFetcher.should_receive(:process_rss_feed_id).
            with(100, nil, true).ordered
        RssFeedFetcher.should_receive(:process_rss_feed_id).
            with(200, nil, true).ordered
        RssFeedFetcher.perform(rss_feed_ids)
      end
    end

    context 'when youtube_profile_id is present' do
      it 'should import using YoutubeData' do
        rss_feed = mock_model(RssFeed, is_video?: true)
        youtube_profile = mock_model(YoutubeProfile)
        RssFeed.should_receive(:find_by_id).with(rss_feed.id).and_return(rss_feed)
        YoutubeProfile.should_receive(:find_by_id).with(youtube_profile.id).and_return(youtube_profile)

        importer = mock('importer')
        YoutubeData.should_receive(:new).with(rss_feed, youtube_profile).and_return(importer)
        importer.should_receive(:import)
        RssFeedFetcher.perform(rss_feed.id, youtube_profile.id)
      end
    end

    context 'when RssFeed is video' do
      let(:rss_feed) { mock_model(RssFeed, is_video?: true) }

      it 'should import using YoutubeData' do
        RssFeed.should_receive(:find_by_id).with(rss_feed.id).and_return(rss_feed)
        importer = mock('importer')
        YoutubeData.should_receive(:new).with(rss_feed).and_return(importer)
        importer.should_receive(:import)
        RssFeedFetcher.perform(rss_feed.id)
      end
    end

    context 'when RssFeed is not video' do
      let(:rss_feed) { mock_model(RssFeed, is_video?: false) }

      it 'should import using RssFeedData' do
        RssFeed.should_receive(:find_by_id).with(rss_feed.id).and_return(rss_feed)
        importer = mock('importer')
        RssFeedData.should_receive(:new).with(rss_feed, true).and_return(importer)
        importer.should_receive(:import)
        RssFeedFetcher.perform(rss_feed.id)
      end
    end
  end
end