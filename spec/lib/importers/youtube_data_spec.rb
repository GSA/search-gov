# frozen_string_literal: true

describe YoutubeData do
  fixtures :affiliates, :rss_feeds, :rss_feed_urls, :youtube_profiles

  describe '.refresh' do
    let(:rss_feed) { mock_model RssFeed }
    let(:profile) { mock_model YoutubeProfile }
    let(:youtube_data) { double described_class }
    let(:active_profiles) { double YoutubeProfile }
    let(:refresh) do
      t = Thread.new { described_class.refresh }
      sleep 0.1
      t.kill
    end

    before do
      allow(YoutubeProfile).to receive(:active).and_return(active_profiles)
      allow(active_profiles).to receive(:stale).and_return([profile], [])
      allow(described_class).to receive(:new).
        with(profile).
        and_return(youtube_data)
      allow(youtube_data).to receive(:import)
    end

    it 'imports each profile' do
      refresh

      expect(youtube_data).to have_received(:import)
      expect(described_class).to have_received(:new).
        with(profile)
    end

    context 'when we have already updated the maximum number of profiles for today' do
      let(:maximum_profile_updates_per_day) do
        Rails.configuration.youtube['maximum_profile_updates_per_day']
      end

      before do
        allow(described_class).to receive(:number_of_profiles_updated_today).
          and_return(maximum_profile_updates_per_day)
      end

      it 'does not import any profiles' do
        refresh

        expect(youtube_data).not_to have_received(:import)
      end
    end
  end

  describe '.number_of_profiles_updated_today' do
    let(:actual_number_of_profiles_updated_today) { nil }

    before do
      YoutubeProfile.all.each do |profile|
        profile.updated_at = Time.now.utc - 1.day
        profile.save!
      end

      YoutubeProfile.take(actual_number_of_profiles_updated_today).each do |profile|
        profile.updated_at = Time.now.utc
        profile.save!
      end
    end

    context 'when no profiles have been updated today' do
      let(:actual_number_of_profiles_updated_today) { 0 }

      it 'returns 0' do
        expect(described_class.number_of_profiles_updated_today).to eq(0)
      end
    end

    context 'when 1 profile has been updated today' do
      let(:actual_number_of_profiles_updated_today) { 1 }

      it 'returns 1' do
        expect(described_class.number_of_profiles_updated_today).to eq(1)
      end
    end

    context 'when 2 profiles have been updated today' do
      let(:actual_number_of_profiles_updated_today) { 2 }

      it 'returns 2' do
        expect(described_class.number_of_profiles_updated_today).to eq(2)
      end
    end
  end

  describe '.maximum_number_of_profile_updates_per_day' do
    context 'when no value is configured' do
      before do
        Rails.configuration.youtube['maximum_profile_updates_per_day'] = nil
      end

      it 'defaults to the value built in to YoutubeData' do
        expect(described_class.maximum_profile_updates_per_day).
          to eq(YoutubeData::DEFAULT_MAXIMUM_PROFILE_UPDATES_PER_DAY)
      end
    end

    context 'when a value is configured' do
      let(:expected_maximum_number_of_profile_updates_per_day) { 31_416 }

      before do
        Rails.configuration.youtube['maximum_profile_updates_per_day'] =
          expected_maximum_number_of_profile_updates_per_day
      end

      it 'defaults to the value built in to YoutubeData' do
        expect(described_class.maximum_profile_updates_per_day).to(
          eq(expected_maximum_number_of_profile_updates_per_day)
        )
      end
    end
  end

  describe '#import' do
    let(:profile) { youtube_profiles(:whitehouse) }
    let(:youtube_data) { described_class.new(profile) }

    before do
      allow(youtube_data).to receive(:import_playlists)
      allow(youtube_data).to receive(:import_playlists_items)
      allow(youtube_data).to receive(:populate_durations)

      youtube_data.import
    end

    it 'synchronizes playlists and playlists_items' do
      expect(youtube_data).to have_received(:import_playlists)
      expect(youtube_data).to have_received(:import_playlists_items)
      expect(youtube_data).to have_received(:populate_durations)
    end

    context 'when YoutubeAdapter raises an error' do
      before do
        allow(YoutubeAdapter).to receive(:get_playlist_ids).
          and_raise('YouTube API')
        allow(Rails.logger).to receive(:warn).with(/YouTube API/)

        described_class.new(profile).import
      end

      it 'logs a warning' do
        expect(YoutubeAdapter).to have_received(:get_playlist_ids)
        expect(Rails.logger).to have_received(:warn).with(/YouTube API/)
      end
    end
  end

  describe '#import_playlists' do
    let(:profile) { youtube_profiles(:whitehouse) }
    let(:expected_playlist_ids) { %w[playlist_1 playlist_2 playlist_3].freeze }

    before do
      %w[playlist_1 playlist_2 obsolete_playlist].each do |playlist_id|
        profile.youtube_playlists.create!(playlist_id: playlist_id)
      end

      allow(YoutubeAdapter).to receive(:get_playlist_ids).
        with('whitehouse_channel_id').
        and_return(expected_playlist_ids)
    end

    it 'imports playlists' do
      youtube_data = described_class.new(profile)
      youtube_data.import_playlists

      playlist_ids = profile.youtube_playlists.pluck(:playlist_id)
      expect(playlist_ids).to eq(expected_playlist_ids)

      obsolete_playlist = profile.youtube_playlists.find_by(
        playlist_id: 'obsolete_playlist'
      )
      expect(obsolete_playlist).to be_nil
      expect(YoutubeAdapter).to have_received(:get_playlist_ids).
        with('whitehouse_channel_id')
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
          }
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
          title: 'video 3 title'
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

    let(:first_result_hash) do
      {
        etag: nil,
        status_code: 304
      }
    end

    let(:first_result) { Hashie::Mash::Rash.new(first_result_hash) }

    let(:second_result_hash) do
      {
        etag: 'playlist_2_etag',
        status_code: 200
      }
    end

    let(:second_result) { Hashie::Mash::Rash.new(second_result_hash) }

    let(:youtube_data) { described_class.new(profile) }

    let(:news_item_3) do
      rss_feed_url.news_items.find_by(link: 'https://www.youtube.com/watch?v=video_3')
    end

    let(:news_item_ids) { [news_item_1.id, news_item_2.id, news_item_3.id] }

    it 'imports playlists items' do
      expect(YoutubeAdapter).to receive(:each_playlist_item).
        with(playlist_1).
        and_return(first_result)

      expect(YoutubeAdapter).to receive(:each_playlist_item).
        with(playlist_2).
        and_yield(playlist_item_1).
        and_yield(playlist_item_2).
        and_yield(playlist_item_3).
        and_return(second_result)

      expect(Rails.logger).to receive(:warn).
        with(/YoutubeData#create_or_update/)

      youtube_data.import_playlists_items

      expect(youtube_data.all_news_item_ids).to eq(news_item_ids)

      playlist = YoutubePlaylist.find(playlist_1.id)
      expect(playlist.news_item_ids).to eq([news_item_1.id, news_item_2.id])

      playlist = YoutubePlaylist.find(playlist_2.id)
      expect(playlist.etag).to eq('playlist_2_etag')
      expect(playlist.news_item_ids).to eq([news_item_1.id, news_item_3.id])

      expect(NewsItem.find_by(id: obsolete_news_item.id)).to be_nil
    end
  end

  describe '#populate_durations' do
    let(:profile) { youtube_profiles(:whitehouse) }
    let(:feed_url) { double('feed url') }

    it 'sets NewsItem#duration' do
      news_item_without_duration = mock_model(NewsItem,
                                              duration: nil,
                                              guid: 'video_1')

      news_item_with_duration = mock_model(NewsItem,
                                           duration: '2:28',
                                           guid: 'video_2')

      youtube_data = described_class.new profile

      allow(youtube_data).to receive(:rss_feed_url).and_return(feed_url)
      allow(feed_url).to receive(:news_items).
        and_return([news_item_without_duration, news_item_with_duration])

      video_1 = Hashie::Mash::Rash.new(id: 'video_1',
                                       contentDetails: {
                                         duration: 'PT5M30S'
                                       })

      expect(YoutubeAdapter).to receive(:each_video).
        with(%w[video_1]).
        and_yield(video_1)

      allow(youtube_data).to receive_message_chain(
        :rss_feed_url, :news_items, :find_by
      ).and_return(news_item_without_duration)
      expect(news_item_without_duration).to receive(:duration=).with('5:30')
      expect(news_item_without_duration).to receive(:save!)

      youtube_data.populate_durations
    end
  end
end
