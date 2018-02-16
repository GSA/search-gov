require 'spec_helper'

describe YoutubeData do
  fixtures :affiliates, :rss_feeds, :rss_feed_urls, :youtube_profiles

  describe '.refresh' do
    let(:rss_feed) { mock_model RssFeed }
    let(:profile) { mock_model YoutubeProfile }
    let(:youtube_data) { double YoutubeData }

    before do
      allow(YoutubeProfile).to receive_message_chain(:active, :stale).and_return([profile], [])
      expect(YoutubeData).to receive(:new).with(profile).and_return youtube_data
    end

    it 'should import each profile' do
      expect(youtube_data).to receive :import

      t = Thread.new { YoutubeData.refresh }
      sleep 0.1
      t.kill
    end
  end

  describe '#import' do
    let(:profile) { youtube_profiles(:whitehouse) }

    it 'synchronizes playlists and playlists_items' do
      youtube_data = YoutubeData.new(profile)

      expect(youtube_data).to receive(:import_playlists)
      expect(youtube_data).to receive(:import_playlists_items)
      expect(youtube_data).to receive(:populate_durations)
      youtube_data.import
    end

    context 'when YoutubeAdapter raises an error' do
      before { expect(YoutubeAdapter).to receive(:get_playlist_ids).and_raise('YouTube API') }

      it 'logs a warning' do
        expect(Rails.logger).to receive(:warn).with(/YouTube API/)
        YoutubeData.new(profile).import
      end
    end
  end

  describe '#import_playlists' do
    let(:profile) { youtube_profiles(:whitehouse) }
    let(:expected_playlist_ids) { %w(playlist_1 playlist_2 playlist_3).freeze }

    before do
      %w(playlist_1 playlist_2 obsolete_playlist).each do |playlist_id|
        profile.youtube_playlists.create!(playlist_id: playlist_id)
      end

      expect(YoutubeAdapter).to receive(:get_playlist_ids).
        with('whitehouse_channel_id').
        and_return(expected_playlist_ids)
    end

    it 'imports playlists' do
      youtube_data = YoutubeData.new(profile)
      youtube_data.import_playlists

      playlist_ids = profile.youtube_playlists.pluck(:playlist_id)
      expect(playlist_ids).to eq(expected_playlist_ids)
      expect(profile.youtube_playlists.find_by_playlist_id('obsolete_playlist')).to be_nil
    end
  end

  describe '#import_playlists_items' do
    let(:profile) { youtube_profiles(:whitehouse) }
    let(:rss_feed_url) { profile.rss_feed.rss_feed_urls.first }

    let!(:news_item_1) do
      news_item_attributes = {
        description: 'video 1 description',
        guid: 'video_1',
        link: 'https://www.youtube.com/watch?v=video_1',
        published_at: Time.current,
        title: 'video 1 title'
      }
      rss_feed_url.news_items.create!(news_item_attributes)
    end

    let!(:news_item_2) do
      news_item_attributes = {
        guid: 'video_id_2',
        link: 'https://www.youtube.com/watch?v=video_id_2',
        published_at: Time.current,
        title: 'video title 2'
      }
      rss_feed_url.news_items.create!(news_item_attributes)
    end

    let!(:obsolete_news_item) do
      news_item_attributes = {
        guid: 'obsolete_video_id',
        link: 'https://www.youtube.com/watch?v=obsolete_video_id',
        published_at: Time.current,
        title: 'obsolete video title'
      }
      rss_feed_url.news_items.create!(news_item_attributes)
    end

    let!(:playlist_1) do
      playlist_attributes = {
        playlist_id: 'playlist_1',
        etag: 'etag_1',
        news_item_ids: [news_item_1.id, news_item_2.id]
      }
      profile.youtube_playlists.create!(playlist_attributes)
    end

    let!(:playlist_2) do
      profile.youtube_playlists.create!(playlist_id: 'playlist_2')
    end

    let(:playlist_item_1) do
      item_hash = {
        snippet: {
          resourceId: {
            videoId: 'video_1'
          },
        }
      }
      Hashie::Mash::Rash.new(item_hash)
    end

    let(:playlist_item_2) do
      item_hash = {
        snippet: {
          description: 'video 3 description',
          publishedAt: Time.current,
          resourceId: {
            videoId: 'video_3'
          },
          title: 'video 3 title',
        }
      }
      Hashie::Mash::Rash.new(item_hash)
    end

    let(:playlist_item_3) do
      item_hash = {
        snippet: {
          description: 'video with missing title',
          publishedAt: Time.current,
          resourceId: {
            videoId: 'video_4'
          }
        }
      }
      Hashie::Mash::Rash.new(item_hash)
    end

    before do
      result_hash = {
        etag: nil,
        status_code: 304
      }
      result = Hashie::Mash::Rash.new(result_hash)

      expect(YoutubeAdapter).to receive(:each_playlist_item).
        with(playlist_1).
        and_return(result)

      result_hash = {
        etag: 'playlist_2_etag',
        status_code: 200
      }
      result = Hashie::Mash::Rash.new(result_hash)

      expect(YoutubeAdapter).to receive(:each_playlist_item).
        with(playlist_2).
        and_yield(playlist_item_1).
        and_yield(playlist_item_2).
        and_yield(playlist_item_3).
        and_return(result)

      expect(Rails.logger).to receive(:warn).with(/YoutubeData#create_or_update/)
    end

    it 'imports playlists items' do
      youtube_data = YoutubeData.new profile
      youtube_data.import_playlists_items

      news_item_3 = rss_feed_url.news_items.find_by_link('https://www.youtube.com/watch?v=video_3')
      news_item_ids = [news_item_1.id, news_item_2.id, news_item_3.id]
      expect(youtube_data.all_news_item_ids).to eq(news_item_ids)

      playlist = YoutubePlaylist.find(playlist_1.id)
      expect(playlist.news_item_ids).to eq([news_item_1.id, news_item_2.id])

      playlist = YoutubePlaylist.find(playlist_2.id)
      expect(playlist.etag).to eq('playlist_2_etag')
      expect(playlist.news_item_ids).to eq([news_item_1.id, news_item_3.id])

      expect(NewsItem.find_by_id(obsolete_news_item.id)).to be_nil
    end
  end

  describe '#populate_durations' do
    let(:profile) { youtube_profiles(:whitehouse) }

    it 'sets NewsItem#duration' do
      news_item_without_duration = mock_model(NewsItem,
                                              duration: nil,
                                              guid: 'video_1')

      news_item_with_duration = mock_model(NewsItem,
                                           duration: '2:28',
                                           guid: 'video_2')

      youtube_data = YoutubeData.new profile

      allow(youtube_data).to receive_message_chain(:rss_feed_url, :news_items).
        and_return([news_item_without_duration, news_item_with_duration])

      video_1 = Hashie::Mash::Rash.new(id: 'video_1',
                                 contentDetails: {
                                   duration: 'PT5M30S'
                                 })

      expect(YoutubeAdapter).to receive(:each_video).
        with(%w(video_1)).
        and_yield(video_1)

      allow(youtube_data).to receive_message_chain(:rss_feed_url, :news_items, :find_by_link).
        and_return(news_item_without_duration)
      expect(news_item_without_duration).to receive(:duration=).with('5:30')
      expect(news_item_without_duration).to receive(:save!)

      youtube_data.populate_durations
    end
  end
end
