require 'spec_helper'

describe YoutubeAdapter do
  let(:client) { YoutubeAdapter.client }
  let(:youtube_api) { YoutubeAdapter.youtube_api }

  describe '.get_channel_id_by_username' do
    context 'when username is valid' do
      it 'returns channel_id' do
        result_hash = {
          data: {
            items: [{ id: 'nasa_channel_id' }]
          },
          success?: true
        }
        result = Hashie::Mash::Rash.new(result_hash)

        execute_params = {
          api_method: youtube_api.channels.list,
          authenticated: false,
          parameters: {
            forUsername: 'nasa',
            part: 'id'
          }
        }
        client.should_receive(:execute).with(execute_params).and_return(result)

        channel_id = described_class.get_channel_id_by_username('nasa')
        expect(channel_id).to eq('nasa_channel_id')
      end
    end

    context 'when username is invalid' do
      it 'returns nil' do
        result_hash = {
          data: {
            items: []
          },
          success?: true
        }
        result = Hashie::Mash::Rash.new(result_hash)

        execute_params = {
          api_method: youtube_api.channels.list,
          authenticated: false,
          parameters: {
            forUsername: 'nasa',
            part: 'id'
          }
        }
        client.should_receive(:execute).with(execute_params).and_return(result)

        expect(described_class.get_channel_id_by_username('nasa')).to be_nil
      end
    end

    context 'when result is not success' do
      it 'logs the error' do
        result_hash = {
          success?: false
        }
        result = Hashie::Mash::Rash.new(result_hash)

        execute_params = {
          api_method: youtube_api.channels.list,
          authenticated: false,
          parameters: {
            forUsername: 'nasa',
            part: 'id'
          }
        }
        client.should_receive(:execute).with(execute_params).and_return(result)

        expect(described_class.get_channel_id_by_username('nasa')).to be_nil
      end
    end
  end

  describe '.get_channel_title' do
    context 'when channel_id is valid' do
      it 'returns a title' do
        result_hash = {
          data: {
            items: [{ id: 'nasa_channel_id',
                      snippet: { title: 'my channel' } }]
          },
          success?: true
        }
        result = Hashie::Mash::Rash.new(result_hash)

        execute_params = {
          api_method: youtube_api.channels.list,
          authenticated: false,
          parameters: {
            id: 'nasa_channel_id',
            part: 'snippet'
          }
        }
        client.should_receive(:execute).with(execute_params).and_return(result)

        expect(described_class.get_channel_title('nasa_channel_id')).to eq('my channel')
      end
    end

    context 'when channel_id is invalid' do
      it 'returns false' do
        result_hash = {
          data: {
            items: []
          },
          success?: true
        }
        result = Hashie::Mash::Rash.new(result_hash)

        execute_params = {
          api_method: youtube_api.channels.list,
          authenticated: false,
          parameters: {
            id: 'nasa_channel_id',
            part: 'snippet'
          }
        }
        client.should_receive(:execute).with(execute_params).and_return(result)

        expect(described_class.get_channel_title('nasa_channel_id')).to be_nil
      end
    end
  end

  describe '.get_playlist_ids' do
    it 'returns playlist ids' do
      described_class.should_receive(:get_uploads_playlist_id).
        with('my_channel_id').
        and_return('upload_playlist_id')
      described_class.should_receive(:get_custom_playlist_ids).
        with('my_channel_id').
        and_return(%w(custom_playlist_id))

      playlist_ids = described_class.get_playlist_ids('my_channel_id')
      expected_playlist_ids = %w(custom_playlist_id upload_playlist_id)
      expect(playlist_ids).to eq(expected_playlist_ids)
    end
  end

  describe '.get_uploads_playlist_id' do
    it 'returns playlist_id' do
      result_hash = {
        data: {
          items: [
            { contentDetails: {
              relatedPlaylists: {
                uploads: 'my_uploads_playlist_id'
              } }
            }
          ]
        },
        success?: true
      }
      result = Hashie::Mash::Rash.new(result_hash)

      execute_params = {
        api_method: youtube_api.channels.list,
        authenticated: false,
        parameters: {
          id: 'nasa_channel_id',
          part: 'contentDetails'
        }
      }

      client.should_receive(:execute).with(execute_params).and_return(result)

      playlist_id = described_class.get_uploads_playlist_id('nasa_channel_id')
      expected_playlist_id = 'my_uploads_playlist_id'
      expect(playlist_id).to eq(expected_playlist_id)
    end
  end

  describe '.get_custom_playlist_ids' do
    it 'returns playlist ids' do
      result_hash = {
        data: {
          items: [
            { id: 'my_custom_playlist_1',
              status: { privacyStatus: 'public' } },
            { id: 'my_custom_playlist_2',
              status: { privacyStatus: 'public' } },
            { id: 'my_custom_playlist_3',
              status: { privacyStatus: 'private' } }
          ]
        },
        success?: true
      }
      result = Hashie::Mash::Rash.new(result_hash)

      execute_params = {
        api_method: youtube_api.playlists.list,
        authenticated: false,
        headers: nil,
        parameters: {
          channelId: 'nasa_channel_id',
          maxResults: 50,
          pageToken: '',
          part: 'id,status'
        }
      }

      client.should_receive(:execute).with(execute_params).and_return(result)

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

    let(:execute_params) do
      { api_method: youtube_api.playlist_items.list,
        authenticated: false,
        headers: { 'If-None-Match' => 'nasa_playlist_etag' },
        parameters: {
          maxResults: 50,
          pageToken: '',
          part: 'snippet,status',
          playlistId: 'nasa_playlist_id'
        }
      }
    end

    it 'yields item' do
      item_hash = {
        status: {
          privacyStatus: 'public'
        }
      }
      item_1 = Hashie::Mash::Rash.new(item_hash)

      item_hash = {
        status: {
          privacyStatus: 'public'
        }
      }
      item_2 = Hashie::Mash::Rash.new(item_hash)

      item_hash = {
        status: {
          privacyStatus: 'private'
        }
      }
      item_3 = Hashie::Mash::Rash.new(item_hash)

      result_hash = {
        data: {
          items: [item_1, item_2, item_3]
        },
        success?: true
      }
      result = Hashie::Mash::Rash.new(result_hash)

      client.should_receive(:execute).with(execute_params).and_return(result)
      expect do |item|
        described_class.each_playlist_item(playlist, &item)
      end.to yield_successive_args(item_1, item_2)
    end

    context 'when the resource has not changed' do
      it 'returns the result' do
        result_hash = {
          status: 304,
          success?: true
        }
        result = Hashie::Mash::Rash.new(result_hash)

        client.should_receive(:execute).with(execute_params).and_return(result)
        expect do |item|
          described_class.each_playlist_item(playlist, &item)
        end.not_to yield_control
      end
    end

    context 'when the result is not success' do
      it 'raises error' do
        result_hash = {
          status: 400,
          success?: false
        }
        result = Hashie::Mash::Rash.new(result_hash)

        client.should_receive(:execute).with(execute_params).and_return(result)
        expect do |item|
          described_class.each_playlist_item(playlist, &item)
        end.to raise_error(/YouTube API status/)
      end
    end
  end

  describe '.each_video' do
    it 'yields item' do
      execute_params = {
        api_method: youtube_api.videos.list,
        authenticated: false,
        parameters: {
          id: 'video_1_id,video_2_id',
          part: 'contentDetails'
        }
      }

      item_1 = double('video_1')
      item_2 = double('video_2')
      result_hash = {
        data: {
          items: [item_1, item_2]
        },
        success?: true
      }
      result = Hashie::Mash::Rash.new(result_hash)

      client.should_receive(:execute).with(execute_params).and_return(result)
      expect do |item|
        described_class.each_video(%w(video_1_id video_2_id), &item)
      end.to yield_successive_args(item_1, item_2)
    end
  end
end
