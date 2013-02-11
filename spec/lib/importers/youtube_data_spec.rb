require 'spec_helper'

describe YoutubeData do
  disconnect_sunspot
  fixtures :affiliates, :rss_feeds, :rss_feed_urls

  describe '#import' do
    context 'when importing a single youtube profile' do
      let(:rss_feed) { rss_feeds(:managed_video) }

      before { rss_feed.news_items.destroy_all }

      it 'should iterate through all videos' do
        uploaded_feed_doc = File.open(Rails.root.to_s + '/spec/fixtures/rss/youtube.xml')
        next_uploaded_feed_doc = File.open(Rails.root.to_s + '/spec/fixtures/rss/next_youtube.xml')
        Kernel.should_receive(:open).twice.and_return(uploaded_feed_doc, next_uploaded_feed_doc)

        profile = mock_model(YoutubeProfile, username: 'whitehouse')
        importer = YoutubeData.new(rss_feed, profile)
        importer.import

        rss_feed.rss_feed_urls.find_by_url(YoutubeProfile.youtube_url('whitehouse')).last_crawl_status.should == RssFeedUrl::OK_STATUS
        rss_feed.news_items(true).count.should == 28

        newest = rss_feed.news_items.first
        newest.guid.should == 'http://gdata.youtube.com/feeds/base/videos/WR595t0HBGE'
        newest.title.should == 'President Obama Honors the Nations TOP COPS'
        newest.description[0, 40].should == 'President Obama Honors the Nations TOP C'
        newest.link.should == 'http://www.youtube.com/watch?v=WR595t0HBGE&feature=youtube_gdata'
        newest.published_at.should == DateTime.parse('Sat, 12 May 2012 16:24:46 +0000')
      end
    end

    context 'when import a managed video rss feed' do
      let(:profile) { YoutubeProfile.new(username: 'whitehouse') }
      let(:another_profile) { YoutubeProfile.new(username: 'usasearch') }
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:rss_feed) { rss_feeds(:managed_video) }
      let(:rss_feed_url) { rss_feed_urls(:playlist_video) }
      let(:link_in_both_uploaded_and_playlists) { 'http://www.youtube.com/watch?v=dN0w8uPnX3s&feature=youtube_gdata' }
      let(:invalid_links) { %w(http://gdata.youtube.com/feeds/base/videos/MOCK1 http://gdata.youtube.com/feeds/base/videos/MOCK2) }

      context 'when YoutubeProfile list has not changed during the import' do
        before do
          rf = RssFeed.find(rss_feed.id)
          managed_feed = rf.rss_feed_urls.find_by_url(YoutubeProfile.youtube_url('whitehouse'))
          rf.news_items.create!(rss_feed_url: managed_feed,
                                      link: 'http://gdata.youtube.com/feeds/base/videos/MOCK1',
                                      title: 'mock title',
                                      description: 'mock description',
                                      published_at: DateTime.current,
                                      guid: 'http://gdata.youtube.com/feeds/base/videos/MOCK1',
                                      updated_at: Time.current.yesterday)

          rf.news_items.create!(rss_feed_url: managed_feed,
                                      link: 'http://gdata.youtube.com/feeds/base/videos/MOCK2',
                                      title: 'mock title',
                                      description: 'mock description',
                                      published_at: DateTime.current,
                                      guid: 'http://gdata.youtube.com/feeds/base/videos/MOCK2',
                                      updated_at: Time.current.yesterday)

          rf.news_items.create!(rss_feed_url: managed_feed,
                                      link: 'http://www.youtube.com/watch?v=WR595t0HBGE&feature=youtube_gdata',
                                      title: 'already exist',
                                      description: 'already exist description',
                                      published_at: DateTime.parse('2012-01-24T17:31:04.000Z'),
                                      guid: 'http://www.youtube.com/watch?v=WR595t0HBGE&feature=youtube_gdata',
                                      updated_at: Time.current.yesterday)

          managed_feed.update_attributes!(last_crawl_status: RssFeedUrl::OK_STATUS)
        end

        it 'should synchronize RssFeedUrls and NewsItems' do
          rss_feed.should_receive(:affiliate).and_return(affiliate)
          affiliate.should_receive(:youtube_profiles).with(true).twice.and_return([profile])

          uploaded_feed_doc = File.open(Rails.root.to_s + '/spec/fixtures/rss/youtube.xml')
          next_uploaded_feed_doc = File.open(Rails.root.to_s + '/spec/fixtures/rss/next_youtube.xml')
          Kernel.should_receive(:open).
              with(%r[^http://gdata.youtube.com/feeds/base/videos\?alt=rss&author=whitehouse&max-results=50&orderby=published&start-index=]).
              twice.
              and_return(uploaded_feed_doc, next_uploaded_feed_doc)

          playlists_feed_doc = File.read(Rails.root.to_s + '/spec/fixtures/rss/simple_youtube_playlists.xml')
          Kernel.should_receive(:open).
              with(%r[^http://gdata.youtube.com/feeds/api/users/whitehouse/playlists\?alt=rss&max-results=50&start-index=]i).
              once.
              and_return(playlists_feed_doc)

          feed_validation_doc = File.open(Rails.root.to_s + '/spec/fixtures/rss/playlist_videos.xml')
          playlist_videos_doc = File.open(Rails.root.to_s + '/spec/fixtures/rss/playlist_videos.xml')
          next_playlist_videos_doc = File.open(Rails.root.to_s + '/spec/fixtures/rss/next_playlist_videos.xml')
          Kernel.should_receive(:open).
              with(%r[^http://gdata.youtube.com/feeds/api/playlists/4B46E2882F13A5F3\?alt=rss]).
              exactly(3).times.
              and_return(feed_validation_doc, playlist_videos_doc, next_playlist_videos_doc)

          importer = YoutubeData.new(rss_feed)
          importer.import

          rss_feed.rss_feed_urls(true).collect(&:url).sort.should == %w(
              http://gdata.youtube.com/feeds/api/playlists/4B46E2882F13A5F3?alt=rss
              http://gdata.youtube.com/feeds/base/videos?alt=rss&author=whitehouse&orderby=published)

          rss_feed.rss_feed_urls(true).collect(&:last_crawl_status).uniq.should == [RssFeedUrl::OK_STATUS]

          rss_feed.news_items(true).count.should == 115
          duplicate_news_items = rss_feed.news_items.where(link: link_in_both_uploaded_and_playlists)
          duplicate_news_items.count.should == 1
          duplicate_news_items.first.rss_feed_url.url.should == profile.url
          rss_feed.news_items.where(link: invalid_links).should be_empty
        end
      end

      context 'when parsers raises an error during the import' do
        before do
          rf = RssFeed.find(rss_feed.id)
          managed_feed = rf.rss_feed_urls.find_by_url(YoutubeProfile.youtube_url('whitehouse'))
          rf.news_items.create!(rss_feed_url: managed_feed,
                                link: 'http://gdata.youtube.com/feeds/base/videos/MOCK1',
                                title: 'mock title',
                                description: 'mock description',
                                published_at: DateTime.current,
                                guid: 'http://gdata.youtube.com/feeds/base/videos/MOCK1',
                                updated_at: Time.current.yesterday)

          rf.news_items.create!(rss_feed_url: managed_feed,
                                link: 'http://gdata.youtube.com/feeds/base/videos/MOCK2',
                                title: 'mock title',
                                description: 'mock description',
                                published_at: DateTime.current,
                                guid: 'http://gdata.youtube.com/feeds/base/videos/MOCK2',
                                updated_at: Time.current.yesterday)

          rf.news_items.create!(rss_feed_url: managed_feed,
                                link: 'http://www.youtube.com/watch?v=WR595t0HBGE&feature=youtube_gdata',
                                title: 'already exist',
                                description: 'already exist description',
                                published_at: DateTime.parse('2012-01-24T17:31:04.000Z'),
                                guid: 'http://www.youtube.com/watch?v=WR595t0HBGE&feature=youtube_gdata',
                                updated_at: Time.current.yesterday)

          managed_feed.update_attributes!(last_crawl_status: RssFeedUrl::OK_STATUS)
        end

        it 'should set RssFeedUrl status to ERROR' do
          rss_feed.should_receive(:affiliate).and_return(affiliate)
          affiliate.should_receive(:youtube_profiles).with(true).twice.and_return([profile])

          uploaded_parser = mock('YoutubeUploadedVideosParser')
          YoutubeUploadedVideosParser.should_receive(:new).and_return(uploaded_parser)
          uploaded_parser.should_receive(:each_item).and_raise

          playlists_feed_doc = File.read(Rails.root.to_s + '/spec/fixtures/rss/simple_youtube_playlists.xml')
          Kernel.should_receive(:open).
              with(%r[^http://gdata.youtube.com/feeds/api/users/whitehouse/playlists\?alt=rss&max-results=50&start-index=]i).
              once.
              and_return(playlists_feed_doc)

          feed_validation_doc = File.open(Rails.root.to_s + '/spec/fixtures/rss/playlist_videos.xml')
          Kernel.should_receive(:open).
              with(%r[^http://gdata.youtube.com/feeds/api/playlists/4B46E2882F13A5F3\?alt=rss]).
              once.
              and_return(feed_validation_doc)

          playlist_parser = mock('YoutubePlaylistVideosParser')
          YoutubePlaylistVideosParser.should_receive(:new).and_return(playlist_parser)
          playlist_parser.should_receive(:each_item).and_raise

          importer = YoutubeData.new(rss_feed)
          importer.import

          rss_feed.rss_feed_urls.find_by_url(YoutubeProfile.youtube_url('whitehouse')).last_crawl_status.should == 'RuntimeError'
          rss_feed.rss_feed_urls.find_by_url('http://gdata.youtube.com/feeds/api/playlists/4B46E2882F13A5F3?alt=rss').last_crawl_status.should == 'RuntimeError'
        end
      end

      context 'when YoutubeProfile list has not changed during the import' do
        before do
          rf = RssFeed.find(rss_feed.id)
          managed_feed = rf.rss_feed_urls.find_by_url(YoutubeProfile.youtube_url('whitehouse'))
          rf.news_items.create!(rss_feed_url: managed_feed,
                                link: 'http://gdata.youtube.com/feeds/base/videos/MOCK1',
                                title: 'mock title',
                                description: 'mock description',
                                published_at: DateTime.current,
                                guid: 'http://gdata.youtube.com/feeds/base/videos/MOCK1',
                                updated_at: Time.current.yesterday)

          rf.news_items.create!(rss_feed_url: managed_feed,
                                link: 'http://gdata.youtube.com/feeds/base/videos/MOCK2',
                                title: 'mock title',
                                description: 'mock description',
                                published_at: DateTime.current,
                                guid: 'http://gdata.youtube.com/feeds/base/videos/MOCK2',
                                updated_at: Time.current.yesterday)

          rf.news_items.create!(rss_feed_url: managed_feed,
                                link: 'http://www.youtube.com/watch?v=WR595t0HBGE&feature=youtube_gdata',
                                title: 'already exist',
                                description: 'already exist description',
                                published_at: DateTime.parse('2012-01-24T17:31:04.000Z'),
                                guid: 'http://www.youtube.com/watch?v=WR595t0HBGE&feature=youtube_gdata',
                                updated_at: Time.current.yesterday)

          managed_feed.update_attributes!(last_crawl_status: RssFeedUrl::OK_STATUS)
        end

        it 'should synchronize RssFeedUrls and NewsItems' do
          rss_feed.should_receive(:affiliate).and_return(affiliate)
          affiliate.should_receive(:youtube_profiles).with(true).twice.and_return([profile])

          uploaded_feed_doc = File.open(Rails.root.to_s + '/spec/fixtures/rss/youtube.xml')
          next_uploaded_feed_doc = File.open(Rails.root.to_s + '/spec/fixtures/rss/next_youtube.xml')
          Kernel.should_receive(:open).
              with(%r[^http://gdata.youtube.com/feeds/base/videos\?alt=rss&author=whitehouse&max-results=50&orderby=published&start-index=]).
              twice.
              and_return(uploaded_feed_doc, next_uploaded_feed_doc)

          playlists_feed_doc = File.read(Rails.root.to_s + '/spec/fixtures/rss/simple_youtube_playlists.xml')
          Kernel.should_receive(:open).
              with(%r[^http://gdata.youtube.com/feeds/api/users/whitehouse/playlists\?alt=rss&max-results=50&start-index=]i).
              once.
              and_return(playlists_feed_doc)

          feed_validation_doc = File.open(Rails.root.to_s + '/spec/fixtures/rss/playlist_videos.xml')
          playlist_videos_doc = File.open(Rails.root.to_s + '/spec/fixtures/rss/playlist_videos.xml')
          next_playlist_videos_doc = File.open(Rails.root.to_s + '/spec/fixtures/rss/next_playlist_videos.xml')
          Kernel.should_receive(:open).
              with(%r[^http://gdata.youtube.com/feeds/api/playlists/4B46E2882F13A5F3\?alt=rss]).
              exactly(3).times.
              and_return(feed_validation_doc, playlist_videos_doc, next_playlist_videos_doc)

          importer = YoutubeData.new(rss_feed)
          importer.import

          rss_feed.rss_feed_urls(true).collect(&:url).sort.should == %w(
              http://gdata.youtube.com/feeds/api/playlists/4B46E2882F13A5F3?alt=rss
              http://gdata.youtube.com/feeds/base/videos?alt=rss&author=whitehouse&orderby=published)

          rss_feed.rss_feed_urls(true).collect(&:last_crawl_status).uniq.should == [RssFeedUrl::OK_STATUS]

          rss_feed.news_items(true).count.should == 115
          duplicate_news_items = rss_feed.news_items.where(link: link_in_both_uploaded_and_playlists)
          duplicate_news_items.count.should == 1
          duplicate_news_items.first.rss_feed_url.url.should == profile.url
          rss_feed.news_items.where(link: invalid_links).should be_empty
        end
      end
    end
  end
end