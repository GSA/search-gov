require 'spec_helper'

describe YoutubeProfile do
  fixtures :youtube_profiles
  let(:valid_attributes) { { username: 'USAgency' }.freeze }

  it { is_expected.to validate_presence_of :channel_id }
  it { is_expected.to have_one(:rss_feed).dependent :destroy }
  it { is_expected.to have_and_belong_to_many :affiliates }

  it do
    is_expected.to have_many(:youtube_playlists).
                   dependent(:destroy).
                   inverse_of(:youtube_profile)
  end

  it do
    is_expected.to validate_uniqueness_of(:channel_id).
      with_message(/has already been added/)
  end

  describe 'Gets the active YoutubeProfiles' do
    let (:profiles) { described_class.active }

    it 'gets the active youtube profiles' do
      expect(described_class.active.count).to equal(2)
    end

    it 'is expected to have uniq values' do
      expect(described_class.active.count).to equal(described_class.active.distinct.count)
    end
  end

  describe '#after_create' do
    it 'creates RssFeed and RssFeedUrl' do
      profile = described_class.create!(channel_id: 'my_channel_id',
                                        title: 'My Awesome Channel')
      expect(profile.rss_feed).to be_present
      expect(profile.rss_feed.rss_feed_urls.first.url).to eq('https://www.youtube.com/channel/my_channel_id')
      expect(profile.rss_feed.navigation).to be_nil
    end
  end

  describe 'imported_today' do
    context 'when no profiles have been updated' do
      it 'returns no profiles' do
        expect(described_class.imported_today).to be_empty
      end
    end

    context 'when one has been updated' do
      before { described_class.first.update!(imported_at: Time.now) }

      it 'returns the updated profile' do
        expect(described_class.imported_today).to eq([described_class.first])
      end
    end
  end
end
