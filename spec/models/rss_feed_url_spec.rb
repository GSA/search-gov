require 'spec_helper'

describe RssFeedUrl do
  fixtures :rss_feeds, :rss_feed_urls

  it { should have_readonly_attribute :rss_feed_owner_type }
  it { should have_readonly_attribute :url }
  it { should have_and_belong_to_many :rss_feeds }
  it { should have_many(:news_items).dependent(:destroy) }
  it { should validate_presence_of :rss_feed_owner_type }
  it { should validate_presence_of :url }
  it { should validate_uniqueness_of(:url).scoped_to(:rss_feed_owner_type).case_insensitive }

  describe 'validation' do
    context 'when the RSS feed is a valid feed' do
      before do
        rss_feed_content = File.open(Rails.root.to_s + '/spec/fixtures/rss/wh_blog.xml')
        HttpConnection.should_receive(:get).with('http://bogus.example.gov/feed/blog').and_return(rss_feed_content)
      end

      it 'should be_valid' do
        expect { RssFeedUrl.create!(rss_feed_owner_type: 'Affiliate',
                                    url: 'http://bogus.example.gov/feed/blog') }.to_not raise_error
      end
    end

    context 'when the URL does not point to an RSS feed' do
      before do
        not_rss_feed_content = File.open(Rails.root.to_s + '/spec/fixtures/html/usa_gov/site_index.html')
        HttpConnection.should_receive(:get).with('http://bogus.example.gov/not_feed/blog').and_return(not_rss_feed_content)
      end

      it 'should not be valid' do
        rss_feed_url = RssFeedUrl.new(rss_feed_owner_type: 'Affiliate',
                                      url: 'http://bogus.example.gov/not_feed/blog')
        rss_feed_url.should_not be_valid
        rss_feed_url.errors.full_messages.should include('Url does not appear to be a valid RSS feed.')
      end
    end

    context 'when some error is raised in checking the RSS feed' do
      before do
        HttpConnection.should_receive(:get).and_raise('Some exception')
      end

      it 'should not be valid' do
        rss_feed_url = RssFeedUrl.new(rss_feed_owner_type: 'Affiliate',
                                      url: 'http://bogus.example.gov/feed/with_error')
        rss_feed_url.should_not be_valid
        rss_feed_url.errors.full_messages.should include('Url does not appear to be a valid RSS feed. Additional information: Some exception')
      end
    end

    context 'when URL has the wrong format' do
      it 'should not be valid' do
        rss_feed_url = RssFeedUrl.new(rss_feed_owner_type: 'Affiliate', url: 'not_a_valid_url')
        rss_feed_url.save.should be_false
        rss_feed_url.errors[:url].should include('is invalid')
      end
    end

    context 'on update' do
      before do
        rss_feed_content = File.open(Rails.root.to_s + '/spec/fixtures/rss/wh_blog.xml')
        HttpConnection.should_receive(:get).once.with('http://bogus.example.gov/feed').and_return(rss_feed_content)
      end

      it 'should not validate url again' do
        rss_feed_url = RssFeedUrl.create!(rss_feed_owner_type: 'Affiliate', url: 'http://bogus.example.gov/feed')
        rss_feed_url.update_attributes!(:last_crawled_at => Time.current)
      end
    end
  end

  describe '#is_video?' do
    context 'when url starts with gdata.youtube.com/feeds/' do
      before do
        rss_feed_content = File.open(Rails.root.to_s + '/spec/fixtures/rss/youtube.xml')
        HttpConnection.should_receive(:get).with('http://gdata.youtube.com/feeds/base/videos?alt=rss&user=USGovernment').and_return(rss_feed_content)
      end

      specify { RssFeedUrl.create!(rss_feed_owner_type: 'Affiliate',
                                   url: 'http://gdata.youtube.com/feeds/base/videos?alt=rss&user=USGovernment').should be_is_video }
    end
  end

  describe '.refresh_affiliate_feeds' do
    it 'should enqueue all non managed feeds' do
      rss_feed_url_1 = mock_model(RssFeedUrl)
      rss_feed_url_2 = mock_model(RssFeedUrl)
      RssFeedUrl.stub_chain(:rss_feed_owned_by_affiliate, :active).
          and_return([rss_feed_url_1, rss_feed_url_2])
      rss_feed_url_1.should_receive(:freshen)
      rss_feed_url_2.should_receive(:freshen)
      RssFeedUrl.refresh_affiliate_feeds
    end
  end

  describe '#freshen' do
    it 'should enqueue RssFeedFetcher' do
      rss_feed_url = rss_feed_urls(:white_house_blog_url)
      Resque.should_receive(:enqueue_with_priority).with(:high, RssFeedFetcher, rss_feed_url.id, true)
      rss_feed_url.freshen
    end

    it 'should not freshen YoutubeProfile RssFeedUrl' do
      rss_feed_url = rss_feed_urls(:youtube_video_url)
      Resque.should_not_receive :enqueue_with_priority
      rss_feed_url.freshen
    end
  end
end
