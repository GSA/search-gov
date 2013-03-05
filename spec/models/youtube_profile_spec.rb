require 'spec_helper'

describe YoutubeProfile do
  fixtures :affiliates

  let(:affiliate) { affiliates(:basic_affiliate) }
  let(:valid_attributes) { { username: 'USAgency', affiliate: affiliate }.freeze }

  before { affiliate.rss_feeds.videos.managed.destroy_all }

  it { should validate_presence_of :username }
  it { should validate_presence_of :affiliate_id }

  it 'should validate username' do
    HttpConnection.should_receive(:get).
        with('http://gdata.youtube.com/feeds/api/users/someinvaliduser').
        and_raise(OpenURI::HTTPError.new('404 Not Found', StringIO.new))

    profile = YoutubeProfile.new(username: 'someinvaliduser', affiliate: affiliate)
    profile.should_not be_valid
    profile.errors[:username].should include('is invalid')
  end

  it 'should handle blank xml when fetching xml profile' do
    HttpConnection.should_receive(:get).
        with('http://gdata.youtube.com/feeds/api/users/accountclosed').
        and_return(StringIO.new(''))
    mock_doc = mock('doc')
    Nokogiri.should_receive(:XML).and_return(mock_doc)
    mock_doc.should_receive(:xpath).and_return([])

    profile = YoutubeProfile.new(username: 'accountclosed', affiliate: affiliate)
    profile.should_not be_valid
  end

  context '#create' do
    it 'should normalize username' do
      HttpConnection.stub(:get) do |arg|
        case arg
        when YoutubeProfile.xml_profile_url('usagency')
          File.open(Rails.root.to_s + '/spec/fixtures/rss/youtube_user.xml')
        when YoutubeProfile.youtube_url('usagency')
          File.open(Rails.root.to_s + '/spec/fixtures/rss/youtube.xml')
        end
      end

      Resque.stub(:enqueue_with_priority)

      YoutubeProfile.create!(valid_attributes)
      YoutubeProfile.new(valid_attributes.merge(username: 'usagency')).should_not be_valid
    end
  end

  context '#after_create' do
    before do
      HttpConnection.stub(:get) do |arg|
        case arg
        when YoutubeProfile.xml_profile_url('usagency'), YoutubeProfile.xml_profile_url('anotheragency')
          File.open(Rails.root.to_s + '/spec/fixtures/rss/youtube_user.xml')
        when YoutubeProfile.youtube_url('usagency'), YoutubeProfile.youtube_url('anotheragency')
          File.open(Rails.root.to_s + '/spec/fixtures/rss/youtube.xml')
        end
      end
    end

    context 'when the affiliate does not have an existing managed video RssFeed' do
      before { affiliate.rss_feeds.managed.videos.destroy_all }

      it 'should create managed RssFeed' do
        Resque.should_receive(:enqueue_with_priority).
            with(:high, RssFeedFetcher, kind_of(Numeric), kind_of(Numeric))
        YoutubeProfile.create!(valid_attributes)
        affiliate.rss_feeds(true).managed.videos.count.should == 1
        affiliate.rss_feeds.managed.videos.first.should be_shown_in_govbox
      end
    end

    context 'when the affiliate has an existing managed video RssFeed' do
      before do
        affiliate.rss_feeds.managed.videos.destroy_all
        YoutubeProfile.create!(valid_attributes.merge(username: 'AnotherAgency'))
      end

      it 'should not create another managed RssFeed' do
        Resque.should_receive(:enqueue_with_priority).
            with(:high, RssFeedFetcher, kind_of(Numeric), kind_of(Numeric))
        profile = YoutubeProfile.create!(valid_attributes)
        managed_video_feeds = affiliate.rss_feeds(true).managed.videos
        managed_video_feeds.count.should == 1
        feed = managed_video_feeds.first
        feed.should be_shown_in_govbox
        feed.rss_feed_urls.count.should == 2
        feed.rss_feed_urls.find_by_url(profile.url).should be_present
      end
    end
  end

  context '#after_destroy' do
    before do
      HttpConnection.stub(:get) do |arg|
        case arg
        when YoutubeProfile.xml_profile_url('usagency'), YoutubeProfile.xml_profile_url('anotheragency')
          File.open(Rails.root.to_s + '/spec/fixtures/rss/youtube_user.xml')
        when YoutubeProfile.youtube_url('usagency'), YoutubeProfile.youtube_url('anotheragency')
          File.open(Rails.root.to_s + '/spec/fixtures/rss/youtube.xml')
        end
      end
    end

    context 'when the affiliate has other youtube profiles' do
      it 'should not hide the managed RssFeed' do
        Resque.should_receive(:enqueue_with_priority).
            with(:high, RssFeedFetcher, kind_of(Numeric), kind_of(Numeric)).twice

        YoutubeProfile.create!(valid_attributes.merge(username: 'AnotherAgency'))
        profile = YoutubeProfile.create!(valid_attributes)
        YoutubeProfile.find(profile.id).destroy
        affiliate.rss_feeds.managed.videos.first.should be_shown_in_govbox
      end
    end

    context 'when the affiliate has no other youtube profiles' do
      it 'should hide the managed RssFeed' do
        Resque.should_receive(:enqueue_with_priority).
            with(:high, RssFeedFetcher, kind_of(Numeric), kind_of(Numeric)).once

        profile = YoutubeProfile.create!(valid_attributes)
        YoutubeProfile.find(profile.id).destroy
        affiliate.rss_feeds.videos.managed.first.navigation.should_not be_is_active
        affiliate.rss_feeds.managed.videos.first.should_not be_shown_in_govbox
      end
    end
  end
end
