require 'spec_helper'

describe YoutubeProfile do
  fixtures :youtube_profiles
  let(:valid_attributes) { { username: 'USAgency' }.freeze }

  it { is_expected.to validate_presence_of :channel_id }
  it { is_expected.to have_one(:rss_feed).dependent :destroy }
  it { is_expected.to have_and_belong_to_many :affiliates }
  it { is_expected.to validate_uniqueness_of(:channel_id).
                with_message(/has already been added/) }
  it do
    is_expected.to have_many(:youtube_playlists).
                   dependent(:destroy).
                   inverse_of(:youtube_profile)
  end
  describe '#after_create' do
    it 'creates RssFeed and RssFeedUrl' do
      profile = YoutubeProfile.create!(channel_id: 'my_channel_id',
                                       title: 'My Awesome Channel')
      expect(profile.rss_feed).to be_present
      expect(profile.rss_feed.rss_feed_urls.first.url).to eq('https://www.youtube.com/channel/my_channel_id')
      expect(profile.rss_feed.navigation).to be_nil
    end
  end
end
