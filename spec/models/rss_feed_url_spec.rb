require 'spec_helper'

describe RssFeedUrl do
  fixtures :rss_feeds, :rss_feed_urls, :news_items

  it { should have_readonly_attribute :rss_feed_owner_type }
  it { should have_readonly_attribute :url }
  it { should have_and_belong_to_many :rss_feeds }
  it { should have_many(:news_items) }
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

      context 'when RSS feed contains a <language> element' do
        before do
          RssFeedData.stub(:extract_language).and_return 'es'
        end

        it 'should assign it' do
          RssFeedUrl.create!(rss_feed_owner_type: 'Affiliate',
                             url: 'http://bogus.example.gov/feed/blog').language.should == 'es'
        end
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
        rss_feed_url = RssFeedUrl.new(rss_feed_owner_type: 'Affiliate', url: 'http: // some invalid /')
        rss_feed_url.save.should be_false
        rss_feed_url.errors[:url].should include('is invalid')
        rss_feed_url.url.should == 'http: // some invalid /'
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

  describe 'on destroy' do
    it 'destroys news items' do
      rss_feed_url = rss_feed_urls(:white_house_blog_url)
      news_item_ids = rss_feed_url.news_items.pluck(:id)
      news_item_ids.should be_present
      rss_feed_url.destroy
      NewsItem.where('id IN (?)', news_item_ids).to_a.should be_empty
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

  describe '.enqueue_destroy_all_inactive' do
    it 'should enqueue all affiliate owned inactive RssFeedUrls' do
      rss_feed_urls = [rss_feed_urls(:white_house_blog_url),
                       rss_feed_urls(:white_house_press_gallery_url)]
      RssFeedUrl.stub_chain(:rss_feed_owned_by_affiliate, :inactive).
          and_return(rss_feed_urls)
      Resque.should_receive(:enqueue_with_priority).
          with(:low, InactiveRssFeedUrlDestroyer, rss_feed_urls(:white_house_blog_url).id)
      Resque.should_receive(:enqueue_with_priority).
          with(:low, InactiveRssFeedUrlDestroyer, rss_feed_urls(:white_house_press_gallery_url).id)

      RssFeedUrl.enqueue_destroy_all_inactive
    end
  end

  describe '.enqueue_destroy_all_news_items_with_404' do
    it 'should enqueue all affiliate owned active RssFeedUrls' do
      rss_feed_urls = [rss_feed_urls(:white_house_blog_url),
                       rss_feed_urls(:white_house_press_gallery_url)]
      RssFeedUrl.stub_chain(:rss_feed_owned_by_affiliate, :active).
          and_return(rss_feed_urls)
      Resque.should_receive(:enqueue_with_priority).
          with(:low, NewsItemsChecker, rss_feed_urls(:white_house_blog_url).id)
      Resque.should_receive(:enqueue_with_priority).
          with(:low, NewsItemsChecker, rss_feed_urls(:white_house_press_gallery_url).id)

      RssFeedUrl.enqueue_destroy_all_news_items_with_404
    end
  end

  describe '#destroy_news_items' do
    it 'should enqueue RssFeedUrlItemsChecker' do
      rss_feed_url = rss_feed_urls(:white_house_blog_url)
      Resque.should_receive(:enqueue_with_priority).with(:low, NewsItemsDestroyer, rss_feed_url.id)
      rss_feed_url.enqueue_destroy_news_items
    end

    it 'should not freshen YoutubeProfile RssFeedUrl' do
      rss_feed_url = rss_feed_urls(:youtube_video_url)
      Resque.should_not_receive :enqueue_with_priority
      rss_feed_url.enqueue_destroy_news_items
    end
  end

  describe '#destroy_news_items' do
    it 'should enqueue RssFeedUrlItemsChecker' do
      rss_feed_url = rss_feed_urls(:white_house_blog_url)
      Resque.should_receive(:enqueue_with_priority).with(:low, NewsItemsDestroyer, rss_feed_url.id)
      rss_feed_url.enqueue_destroy_news_items
    end

    it 'should not freshen YoutubeProfile RssFeedUrl' do
      rss_feed_url = rss_feed_urls(:youtube_video_url)
      Resque.should_not_receive :enqueue_with_priority
      rss_feed_url.enqueue_destroy_news_items
    end
  end

  describe '.find_existing_or_initialize' do
    let(:existing_url) { rss_feed_urls(:white_house_blog_url) }
    let(:existing_url_without_scheme) { existing_url.url.sub(/^https?:\/\//i, '') }
    let(:existing_url_in_other_protocol) { "https://#{existing_url_without_scheme}" }

    it 'should find existing URL in HTTP or HTTPS protocol' do
      expect(RssFeedUrl.rss_feed_owned_by_affiliate.
                 find_existing_or_initialize(existing_url_without_scheme)).to eq(existing_url)
    end

    it 'should find existing URL in other protocol' do
      expect(RssFeedUrl.rss_feed_owned_by_affiliate.
                 find_existing_or_initialize(existing_url_in_other_protocol)).to eq(existing_url)
    end
  end
end
