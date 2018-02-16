require 'spec_helper'

describe YoutubeProfileData do
  describe '.import_profile' do
    let(:profile) { mock_model(YoutubeProfile) }

    context 'when url refers to a YouTube user' do
      let(:url) { 'http://www.youtube.com/user/WHITEHOUSE' }

      before do
        expect(described_class).to receive(:import_profile_by_username).
          with('whitehouse').
          and_return(profile)
      end

      it 'returns profile' do
        expect(described_class.import_profile(url)).to eq(profile)
      end
    end

    context 'when url refers to a valid channel' do
      let(:url) { 'http://www.youtube.com/channel/whitehouse_channel' }

      before do
        expect(described_class).to receive(:import_profile_by_channel_id).
          with('whitehouse_channel').
          and_return(profile)
      end

      it 'returns profile' do
        expect(described_class.import_profile(url)).to eq(profile)
      end
    end

    context 'when url format is not a valid' do
      let(:url) { 'http://www.youtube.com/some/video' }

      it 'returns profile' do
        expect(described_class.import_profile(url)).to be_nil
      end
    end
  end

  describe '.import_profile_by_channel_id' do
    let(:channel_id) { 'whitehouse_channel'.freeze }
    let(:profile) { mock_model(YoutubeProfile) }

    before do
      yt_arel = double('YoutubeProfile arel')
      expect(YoutubeProfile).to receive(:where).
        with(channel_id: channel_id).
        and_return(yt_arel)
      expect(yt_arel).to receive(:first_or_initialize).and_return(profile)
    end

    context 'when YoutubeProfile exists in the system' do
      before { expect(profile).to receive(:new_record?).and_return(false) }

      it 'returns profile' do
        expect(described_class.import_profile_by_channel_id(channel_id)).to eq(profile)
      end
    end

    context 'when YoutubeProfile does not exist in the system' do
      before do
        expect(YoutubeAdapter).to receive(:get_channel_title).
          with(channel_id).
          and_return('my awesome channel')

        expect(profile).to receive(:new_record?).and_return(true)
        expect(profile).to receive(:title=).with('my awesome channel')
        expect(profile).to receive(:save).and_return(true)
      end

      it 'returns profile' do
        expect(described_class.import_profile_by_channel_id(channel_id)).to eq(profile)
      end
    end

    context 'when the channel_id is not valid' do
      before do
        expect(YoutubeAdapter).to receive(:get_channel_title).
          with(channel_id).
          and_return(nil)

        expect(profile).to receive(:new_record?).and_return(true)
        expect(profile).to receive(:title=).with(nil)
        expect(profile).to receive(:save).and_return(false)
      end

      it 'returns nil' do
        expect(described_class.import_profile_by_channel_id(channel_id)).to be_nil
      end
    end
  end

  describe '.detect_url' do
    context 'when url domain is not youtube.com' do
      it 'returns blank' do
        url = 'https://www.instagram.com/USERNAME'
        expect(described_class.detect_url(url)).to be_blank
      end
    end

    context 'when url format is https://www.youtube.com/USERNAME' do
      it 'returns [:user, "USERNAME"]' do
        url = 'https://www.youtube.com/USERNAME'
        expect(described_class.detect_url(url)).to eq([:user, 'USERNAME'])
      end
    end

    context 'when url path starts with /watch or /playlist' do
      it 'returns blank' do
        url = 'https://www.youtube.com/watch?v=video_id'
        expect(described_class.detect_url(url)).to be_blank

        url = 'https://www.youtube.com/playlist?list=playlist_id'
        expect(described_class.detect_url(url)).to be_blank
      end
    end
  end
end
