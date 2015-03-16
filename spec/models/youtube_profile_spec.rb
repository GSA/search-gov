require 'spec_helper'

describe YoutubeProfile do
  fixtures :youtube_profiles
  let(:valid_attributes) { { username: 'USAgency' }.freeze }

  it { should validate_presence_of :channel_id }
  it { should have_one(:rss_feed).dependent :destroy }
  it { should have_and_belong_to_many :affiliates }
  it { should validate_uniqueness_of(:channel_id).
                with_message(/has already been added/) }

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
