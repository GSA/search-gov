require 'spec_helper'

describe YoutubeData do
  fixtures :affiliates, :rss_feeds, :rss_feed_urls, :youtube_profiles

  describe '.refresh_feeds' do
    let(:rss_feed) { mock_model RssFeed }
    let(:profile) { mock_model YoutubeProfile, rss_feed: rss_feed }
    let(:youtube_data) { mock YoutubeData }

    before do
      YoutubeProfile.should_receive(:active).and_return [profile]
      YoutubeProfile.should_receive(:find_by_id).with(profile.id).and_return profile
      YoutubeData.should_receive(:new).with(profile).and_return youtube_data
      rss_feed.should_receive :touch
    end

    it 'should import each profile' do
      youtube_data.should_receive :import
      YoutubeData.refresh_feeds
    end

    it 'should print out error message when import raises an error' do
      youtube_data.should_receive(:import).and_raise
      Rails.logger.should_receive(:error).with /Failed to import/
      YoutubeData.refresh_feeds
    end
  end

  describe '.import_profile' do
    context 'when username is valid' do
      before do
        user_doc = Rails.root.join('spec/fixtures/rss/youtube_user.xml').read
        DocumentFetcher.should_receive(:fetch).
            with('http://gdata.youtube.com/feeds/api/users/whitehouse').
            and_return({ body: user_doc })
      end

      it 'returns YoutubeProfile' do
        profile = YoutubeData.import_profile('whitehouse')
        profile.id.should be_present
        profile.username.should == 'whitehouse'
      end
    end

    context 'when username is not valid' do
      before do
        DocumentFetcher.should_receive(:fetch).
            with('http://gdata.youtube.com/feeds/api/users/whitehouse').
            and_return({})
      end

      specify { YoutubeData.import_profile('whitehouse').should be_nil }
    end
  end

  describe '#import' do
    let(:profile) { youtube_profiles(:whitehouse) }
    let(:rss_feed) { rss_feeds(:youtube_feed) }
    let(:rss_feed_url) { rss_feed_urls(:youtube_video_url) }
    let(:link_in_both_uploaded_and_playlists) do
      %w(http://www.youtube.com/watch?v=lrVQPos6bvw&feature=youtube_gdata
         http://www.youtube.com/watch?v=ZUrRTnKjX8Y&feature=youtube_gdata
         http://www.youtube.com/watch?v=nrcV9IZ6dqs&feature=youtube_gdata)
    end

    let(:invalid_links) { %w(http://gdata.youtube.com/feeds/base/videos/MOCK1
                             http://gdata.youtube.com/feeds/base/videos/MOCK2
                             http://www.youtube.com/watch?v=S6slVd1xFcs&feature=youtube_gdata
                             http://www.youtube.com/watch?v=nQ0Hho9ktgI&feature=youtube_gdata
                             http://www.youtube.com/watch?v=fOvVwk5LlQM&feature=youtube_gdata
                             http://www.youtube.com/watch?v=KkXQvtaUmpQ&feature=youtube_gdata) }

    before do
      NewsItem.destroy_all
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
      uploaded_feed_doc = Rails.root.join('spec/fixtures/rss/uploaded_videos.xml').read
      next_uploaded_feed_doc = Rails.root.join('spec/fixtures/rss/next_uploaded_videos.xml').read
      YoutubeConnection.should_receive(:get).
          with(%r[^http://gdata.youtube.com/feeds/api/videos\?alt=rss&author=whitehouse&max-results=50&orderby=published&start-index=]).
          twice.
          and_return(uploaded_feed_doc, next_uploaded_feed_doc)

      playlists_feed_doc = Rails.root.join('spec/fixtures/rss/simple_youtube_playlists.xml').read
      YoutubeConnection.should_receive(:get).
          with(%r[^http://gdata.youtube.com/feeds/api/users/whitehouse/playlists\?alt=rss&max-results=50&start-index=]i).
          and_return(playlists_feed_doc)

      playlist_videos_doc = Rails.root.join('spec/fixtures/rss/playlist_videos.xml').read
      next_playlist_videos_doc = Rails.root.join('spec/fixtures/rss/next_playlist_videos.xml').read
      YoutubeConnection.should_receive(:get).
          with(%r[^http://gdata.youtube.com/feeds/api/playlists/PLRJNAhZxtqH_Sciw0wjqOEuuygrYa1JW7\?alt=rss]).
          and_return(playlist_videos_doc, next_playlist_videos_doc)

      Rails.logger.should_not_receive(:error)
      Rails.logger.should_not_receive(:warn)

      importer = YoutubeData.new(profile)
      importer.import

      rss_feed.rss_feed_urls(true).collect(&:url).sort.should == %w(
              http://gdata.youtube.com/feeds/api/playlists/PLRJNAhZxtqH_Sciw0wjqOEuuygrYa1JW7?alt=rss
              http://gdata.youtube.com/feeds/api/videos?alt=rss&author=whitehouse&orderby=published)

      RssFeedUrl.rss_feed_owned_by_youtube_profile.
          where(url: 'http://gdata.youtube.com/feeds/api/videos?alt=rss&author=whitehouse&orderby=published').
          first.news_items.count.should == 50

      RssFeedUrl.rss_feed_owned_by_youtube_profile.
          where(url: 'http://gdata.youtube.com/feeds/api/playlists/PLRJNAhZxtqH_Sciw0wjqOEuuygrYa1JW7?alt=rss').
          first.news_items.count.should == 43

      rss_feed.rss_feed_urls(true).collect(&:last_crawl_status).uniq.should == [RssFeedUrl::OK_STATUS]

      rss_feed.news_items(true).count.should == 93

      rss_feed.news_items.find_by_link('http://www.youtube.com/watch?v=lrVQPos6bvw&feature=youtube_gdata').
          published_at.to_date.should == Date.parse('2014-05-01')
      rss_feed.news_items.find_by_link('http://www.youtube.com/watch?v=nrcV9IZ6dqs&feature=youtube_gdata').
          duration.should == '1:19:58'

      duplicate_news_items = rss_feed.news_items.where(link: link_in_both_uploaded_and_playlists)
      duplicate_news_items.count.should == 3
      duplicate_news_items.map(&:rss_feed_url).map(&:url).uniq.should == [profile.url]
      NewsItem.where(link: invalid_links).should be_empty
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
        rss_feed.rss_feed_urls.find_by_url('http://gdata.youtube.com/feeds/api/playlists/PLRJNAhZxtqH_Sciw0wjqOEuuygrYa1JW7?alt=rss').last_crawl_status.should == 'RuntimeError'
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
        Rails.logger.should_receive(:warn).with /^YoutubeData#create\_or\_update/
        importer.import

        rss_feed.news_items(true).count.should == 2
      end
    end
  end
end
