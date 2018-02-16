require 'spec_helper'

describe YoutubeAdapter do
  let(:client) { YoutubeAdapter.client }

  describe '.get_channel_id_by_username' do
    let(:result) { nil }
    let(:error) { nil }

    before do
      expect(client).to receive(:list_channels).with('id', for_username: 'nasa') do |&block|
        block.call(result, error)
      end
    end

    context 'when username is valid' do
      let(:result) do
        Hashie::Mash.new(
          items: [{ id: 'nasa_channel_id' }]
        )
      end

      it 'returns channel_id' do
        channel_id = described_class.get_channel_id_by_username('nasa')
        expect(channel_id).to eq('nasa_channel_id')
      end
    end

    context 'when username is invalid' do
      let(:result) { Hashie::Mash.new(items: []) }

      it 'returns nil' do
        expect(described_class.get_channel_id_by_username('nasa')).to be_nil
      end
    end

    context 'when result is not success' do
      let(:error) { Hashie::Mash.new(status_code: 400) }

      it 'logs the error' do
        expect(described_class.get_channel_id_by_username('nasa')).to be_nil
      end
    end
  end

  describe '.get_channel_title' do
    let(:result) { nil }
    let(:error) { nil }
    before do
      expect(client).to receive(:list_channels).with('snippet', id: 'nasa_channel_id') do |&block|
        block.call(result, error)
      end
    end

    context 'when channel_id is valid' do
      let(:result) do
        Hashie::Mash.new(items: [
          { id: 'nasa_channel_id', snippet: { title: 'my channel' } }
        ])
      end
      it 'returns a title' do
        expect(described_class.get_channel_title('nasa_channel_id')).to eq('my channel')
      end
    end

    context 'when channel_id is invalid' do
      let(:result) { Hashie::Mash.new(items: []) }
      it 'returns false' do
        expect(described_class.get_channel_title('nasa_channel_id')).to be_nil
      end
    end
  end

  describe '.get_playlist_ids' do
    it 'returns playlist ids' do
      expect(described_class).to receive(:get_uploads_playlist_id).
        with('my_channel_id').
        and_return('upload_playlist_id')
      expect(described_class).to receive(:get_custom_playlist_ids).
        with('my_channel_id').
        and_return(%w(custom_playlist_id))

      playlist_ids = described_class.get_playlist_ids('my_channel_id')
      expected_playlist_ids = %w(custom_playlist_id upload_playlist_id)
      expect(playlist_ids).to eq(expected_playlist_ids)
    end
  end

  describe '.get_uploads_playlist_id' do
    let(:result) do
      Hashie::Mash.new(items: [{
        content_details: {
          related_playlists: {
            uploads: 'my_uploads_playlist_id'
          }
        }
      }])
    end

    before do
      expect(client).to receive(:list_channels).with('contentDetails', id: 'nasa_channel_id') do |&block|
        block.call(result)
      end
    end
    it 'returns playlist_id' do
      playlist_id = described_class.get_uploads_playlist_id('nasa_channel_id')
      expected_playlist_id = 'my_uploads_playlist_id'
      expect(playlist_id).to eq(expected_playlist_id)
    end
  end

  describe '.get_custom_playlist_ids' do
    let(:result) do
      Hashie::Mash.new(items: [
        { id: 'my_custom_playlist_1',
          status: { privacy_status: 'public' } },
        { id: 'my_custom_playlist_2',
          status: { privacy_status: 'public' } },
        { id: 'my_custom_playlist_3',
          status: { privacy_status: 'private' } }
      ])
    end

    before do
      expect(client).to receive(:list_playlists).with(
        'id,status',
        channel_id:  'nasa_channel_id',
        max_results: 50,
        page_token:  '',
        options:     Google::Apis::RequestOptions.new,
      ) do |&block|
        block.call(result)
      end
    end
    it 'returns playlist ids' do
      playlist_ids = described_class.get_custom_playlist_ids('nasa_channel_id')
      expected_playlist_ids = %w(my_custom_playlist_1 my_custom_playlist_2)
      expect(playlist_ids).to eq(expected_playlist_ids)
    end
  end

  describe '.each_playlist_item' do
    let(:playlist) do
      mock_model(YoutubePlaylist,
                 etag: 'nasa_playlist_etag',
                 playlist_id: 'nasa_playlist_id')
    end

    let(:result) do
      Hashie::Mash.new(
        items: [
          { status: { privacy_status: 'public' } },
          { status: { privacy_status: 'public' } },
          { status: { privacy_status: 'private' } },
        ]
      )
    end
    let(:error) { nil }
    let(:request_options) do
      request_options = Google::Apis::RequestOptions.new
      request_options.header = { 'If-None-Match' => 'nasa_playlist_etag' }
      request_options
    end

    before do
      expect(client).to receive(:list_playlist_items).with(
        'snippet,status',
        max_results: 50,
        page_token: '',
        playlist_id: 'nasa_playlist_id',
        options: request_options,
      ) do |&block|
        block.call(result, error)
      end
    end

    it 'yields item' do
      expect do |item|
        described_class.each_playlist_item(playlist, &item)
      end.to yield_successive_args(result.items[0], result.items[1])
    end

    context 'when the resource has not changed' do
      let(:error) { Hashie::Mash.new(status_code: 304) }
      it 'returns the result' do
        expect do |item|
          described_class.each_playlist_item(playlist, &item)
        end.not_to yield_control
      end
    end

    context 'when the result is not success' do
      let(:result) { nil }
      let(:error) { Hashie::Mash.new(status_code: 400, message: 'Go away') }

      it 'raises error' do
        expect do |item|
          described_class.each_playlist_item(playlist, &item)
        end.to raise_error(/YouTube API status/)
      end
    end
  end

  describe '.each_video' do
    let(:result) { Hashie::Mash.new(items: [double('video_1'), double('video_2')]) }
    before do
      expect(client).to receive(:list_videos).with('contentDetails', id: 'video_1_id,video_2_id') do |&block|
        block.call(result)
      end
    end

    it 'yields item' do
      expect do |item|
        described_class.each_video(%w(video_1_id video_2_id), &item)
      end.to yield_successive_args(result.items[0], result.items[1])
    end
  end
end
