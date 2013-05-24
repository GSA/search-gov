require 'spec_helper'

describe YoutubeData do
  disconnect_sunspot
  fixtures :affiliates, :rss_feeds, :rss_feed_urls, :youtube_profiles

  describe '.refresh_feeds' do
    let(:rss_feed) { mock_model RssFeed }
    let(:profile) { mock_model YoutubeProfile, rss_feed: rss_feed }
    let(:youtube_data) { mock YoutubeData }

    before do
      YoutubeProfile.should_receive(:active).and_return [profile]
      YoutubeData.should_receive(:new).with(profile).and_return youtube_data
      rss_feed.should_receive :touch
    end

    it 'should import each profile' do
      youtube_data.should_receive :import
      YoutubeData.refresh_feeds
    end

    it 'should print out error message when import raises an error' do
      youtube_data.should_receive(:import).and_raise
      YoutubeData.should_receive(:puts).with /^Failed to import/
      YoutubeData.refresh_feeds
    end
  end

  describe '#import' do
    let(:profile) { youtube_profiles(:whitehouse) }
    let(:rss_feed) { rss_feeds(:youtube_feed) }
    let(:rss_feed_url) { rss_feed_urls(:youtube_video_url) }
    let(:link_in_both_uploaded_and_playlists) { 'http://www.youtube.com/watch?v=dN0w8uPnX3s&feature=youtube_gdata' }
    let(:invalid_links) { %w(http://gdata.youtube.com/feeds/base/videos/MOCK1 http://gdata.youtube.com/feeds/base/videos/MOCK2) }

    before do
      NewsItem.create!(rss_feed_url: rss_feed_url,
                       link: 'http://gdata.youtube.com/feeds/base/videos/MOCK1',
                       title: 'mock title',
                       description: 'mock description',
                       published_at: DateTime.current,
                       guid: 'http://gdata.youtube.com/feeds/base/videos/MOCK1',
                       updated_at: Time.current.yesterday)

      NewsItem.create!(rss_feed_url: rss_feed_url,
                       link: 'http://gdata.youtube.com/feeds/base/videos/MOCK2',
                       title: 'mock title',
                       description: 'mock description',
                       published_at: DateTime.current,
                       guid: 'http://gdata.youtube.com/feeds/base/videos/MOCK2',
                       updated_at: Time.current.yesterday)

      NewsItem.create!(rss_feed_url: rss_feed_url,
                       link: 'http://www.youtube.com/watch?v=WR595t0HBGE&feature=youtube_gdata',
                       title: 'already exist',
                       description: 'already exist description',
                       published_at: DateTime.parse('2012-01-24T17:31:04.000Z'),
                       guid: 'http://gdata.youtube.com/feeds/base/videos/WR595t0HBGE',
                       updated_at: Time.current.yesterday)
    end

    it 'should synchronize RssFeedUrls and NewsItems' do
      uploaded_feed_doc = File.open(Rails.root.to_s + '/spec/fixtures/rss/youtube.xml')
      next_uploaded_feed_doc = File.open(Rails.root.to_s + '/spec/fixtures/rss/next_youtube.xml')
      YoutubeConnection.should_receive(:get).
          with(%r[^http://gdata.youtube.com/feeds/api/videos\?alt=rss&author=whitehouse&max-results=50&orderby=published&start-index=]).
          twice.
          and_return(uploaded_feed_doc, next_uploaded_feed_doc)

      playlists_feed_doc = File.read(Rails.root.to_s + '/spec/fixtures/rss/simple_youtube_playlists.xml')
      YoutubeConnection.should_receive(:get).
          with(%r[^http://gdata.youtube.com/feeds/api/users/whitehouse/playlists\?alt=rss&max-results=50&start-index=]i).
          and_return(playlists_feed_doc)

      playlist_videos_doc = File.open(Rails.root.to_s + '/spec/fixtures/rss/playlist_videos.xml')
      next_playlist_videos_doc = File.open(Rails.root.to_s + '/spec/fixtures/rss/next_playlist_videos.xml')
      YoutubeConnection.should_receive(:get).
          with(%r[^http://gdata.youtube.com/feeds/api/playlists/4B46E2882F13A5F3\?alt=rss]).
          and_return(playlist_videos_doc, next_playlist_videos_doc)

      importer = YoutubeData.new(profile)
      importer.import

      rss_feed.rss_feed_urls(true).collect(&:url).sort.should == %w(
              http://gdata.youtube.com/feeds/api/playlists/4B46E2882F13A5F3?alt=rss
              http://gdata.youtube.com/feeds/api/videos?alt=rss&author=whitehouse&orderby=published)

      rss_feed.rss_feed_urls(true).collect(&:last_crawl_status).uniq.should == [RssFeedUrl::OK_STATUS]

      rss_feed.news_items(true).count.should == 115
      duplicate_news_items = rss_feed.news_items.where(link: link_in_both_uploaded_and_playlists)
      duplicate_news_items.count.should == 1
      duplicate_news_items.first.rss_feed_url.url.should == profile.url
      rss_feed.news_items.where(link: invalid_links).should be_empty
    end

    context 'when parsers raises an error during the import' do
      it 'should set RssFeedUrl status to ERROR' do
        uploaded_parser = mock('YoutubeUploadedVideosParser')
        YoutubeUploadedVideosParser.should_receive(:new).and_return(uploaded_parser)
        uploaded_parser.should_receive(:each_item).and_raise

        playlists_feed_doc = File.read(Rails.root.to_s + '/spec/fixtures/rss/simple_youtube_playlists.xml')
        YoutubeConnection.should_receive(:get).
            with(%r[^http://gdata.youtube.com/feeds/api/users/whitehouse/playlists\?alt=rss&max-results=50&start-index=]i).
            once.
            and_return(playlists_feed_doc)

        playlist_parser = mock('YoutubePlaylistVideosParser')
        YoutubePlaylistVideosParser.should_receive(:new).and_return(playlist_parser)
        playlist_parser.should_receive(:each_item).and_raise

        importer = YoutubeData.new(profile)
        importer.import

        rss_feed.rss_feed_urls.find_by_url(profile.url).last_crawl_status.should == 'RuntimeError'
        rss_feed.rss_feed_urls.find_by_url('http://gdata.youtube.com/feeds/api/playlists/4B46E2882F13A5F3?alt=rss').last_crawl_status.should == 'RuntimeError'
      end
    end

    context 'when one of the items is invalid' do
      it 'should ignore the item' do
        uploaded_feed_doc = File.open(Rails.root.to_s + '/spec/fixtures/rss/youtube_missing_title.xml')
        YoutubeConnection.should_receive(:get).
            with(%r[^http://gdata.youtube.com/feeds/api/videos\?alt=rss&author=whitehouse&max-results=50&orderby=published&start-index=]).
            and_return(uploaded_feed_doc)

        playlists_feed_doc = File.read(Rails.root.to_s + '/spec/fixtures/rss/no_entry_playlist.xml')
        YoutubeConnection.should_receive(:get).
            with(%r[^http://gdata.youtube.com/feeds/api/users/whitehouse/playlists\?alt=rss&max-results=50&start-index=]i).
            and_return(playlists_feed_doc)

        importer = YoutubeData.new(profile)
        importer.should_receive(:puts).with /^Failed to create_or_update/
        importer.import

        rss_feed.news_items(true).count.should == 2
      end
    end
  end
end
