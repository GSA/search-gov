require 'spec_helper'

describe RssFeedUrl do
  fixtures :rss_feeds, :rss_feed_urls, :news_items

  let(:rss_feed_url) { rss_feed_urls(:basic_url) }

  it { should have_readonly_attribute :rss_feed_owner_type }
  it { should have_and_belong_to_many :rss_feeds }
  it { should have_many(:news_items) }
  it { should validate_presence_of :rss_feed_owner_type }
  it { should validate_presence_of :url }
  it { should validate_uniqueness_of(:url).scoped_to(:rss_feed_owner_type).case_insensitive }

  describe 'validation' do
    context 'when the RSS feed is a valid feed' do
      let(:rss_feed_content) { File.open(Rails.root.to_s + '/spec/fixtures/rss/wh_blog.xml') }

      before do
        stub_request(:get, 'http://bogus.example.gov/feed/blog').to_return({ body: rss_feed_content })
      end

      it 'should be_valid' do
        expect { RssFeedUrl.create!(rss_feed_owner_type: 'Affiliate',
                                    url: 'http://bogus.example.gov/feed/blog') }.to_not raise_error
      end

      context 'when RSS feed contains a <language> element' do
        before do
          RssDocument.any_instance.stub(:language).and_return 'es'
        end

        it 'should assign it' do
          RssFeedUrl.create!(rss_feed_owner_type: 'Affiliate',
                             url: 'http://bogus.example.gov/feed/blog').language.should == 'es'
        end
      end

      context 'on create' do
        it 'should enqueue the possible notification to Oasis' do
          Resque.should_receive(:enqueue_with_priority).with(:high, OasisMrssNotification, be_a(Integer))
          RssFeedUrl.create!(rss_feed_owner_type: 'Affiliate', url: 'http://bogus.example.gov/feed/blog')
        end
      end
    end

    context 'when the URL does not point to an RSS feed' do
      before do
        not_rss_feed_content = File.open(Rails.root.to_s + '/spec/fixtures/html/usa_gov/site_index.html')
        stub_request(:get, 'http://bogus.example.gov/not_feed/blog').to_return({ body: not_rss_feed_content })
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
        DocumentFetcher.should_receive(:fetch).and_raise('Some exception')
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
        rss_feed_url.save.should be false
        rss_feed_url.errors[:url].should include('is invalid')
        rss_feed_url.url.should == 'http: // some invalid /'
      end
    end

    context 'on update' do
      before do
        rss_feed_content = File.open(Rails.root.to_s + '/spec/fixtures/rss/wh_blog.xml')
        stub_request(:get, 'http://www.whitehouse.gov/blog').to_return({ body: rss_feed_content })
      end

      context 'when updating the url' do
        let(:rss_feed_url) do
          RssFeedUrl.create(rss_feed_owner_type: 'Affiliate',
                            url: 'http://www.whitehouse.gov/blog')
        end

        context 'for a protocol change' do
          let(:new_url) { 'https://www.whitehouse.gov/blog' }
          it 'is allowed' do
            rss_feed_url.url = new_url
            expect(rss_feed_url.valid?).to be true
          end

          it 'validates the url again' do
            expect(rss_feed_url).to receive(:url_must_point_to_a_feed)
            rss_feed_url.update_attributes(url: new_url)
          end
        end

        context 'for a non-protocol change' do
          let(:new_url) { 'http://www.newanddifferent.gov/blog' }
          it 'is not allowed' do
            rss_feed_url.url = new_url
            expect(rss_feed_url.valid?).to be false
            expect(rss_feed_url.errors[:url]).to include('is read-only except for a protocol change')
          end
        end
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
    context 'when url starts with https://gdata.youtube.com/feeds/' do
      specify { RssFeedUrl.create!(rss_feed_owner_type: 'YoutubeProfile',
                                   url: 'http://gdata.youtube.com/feeds/base/videos?alt=rss&user=USGovernment').should be_is_video }
    end

    context 'when url starts with https://www.youtube.com/channel/' do
      specify { RssFeedUrl.create!(rss_feed_owner_type: 'YoutubeProfile',
                                   url: 'https://www.youtube.com/channel/UCYxRlFDqcWM4y7FfpiAN3KQ').should be_is_video }
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
      Resque.should_receive(:enqueue).with(RssFeedFetcher, rss_feed_url.id, true)
      rss_feed_url.freshen
    end

    it 'should not freshen YoutubeProfile RssFeedUrl' do
      rss_feed_url = rss_feed_urls(:whitehouse_youtube_url)
      Resque.should_not_receive :enqueue
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
    it 'enqueues affiliate own active RssFeedUrls' do
      non_throttled_hosts = %w(www.whitehouse.gov some.agency.gov)
      RssFeedUrl.should_receive(:unique_non_throttled_hosts).and_return(non_throttled_hosts)
      RssFeedUrl.should_receive(:enqueue_destroy_all_news_items_with_404_by_hosts).with(non_throttled_hosts)
      RssFeedUrl.should_receive(:enqueue_destroy_all_news_items_with_404_by_hosts).with(%w(www.army.mil), true)

      RssFeedUrl.enqueue_destroy_all_news_items_with_404
    end
  end

  describe '.enqueue_destroy_all_news_items_with_404_by_hosts' do
    let(:rss_feed_url1) { rss_feed_urls(:white_house_blog_url) }
    let(:rss_feed_url2) { rss_feed_urls(:basic_url) }

    before do
      active_rss_feed_urls = double('active RssFeedUrls')

      wh_rss_feed_urls = double('wh rss feed_urls', pluck: [rss_feed_url1.id])
      basic_rss_feed_urls = double('basic rss feed_urls', pluck: [rss_feed_url2.id])

      RssFeedUrl.stub_chain(:rss_feed_owned_by_affiliate, :active).
          and_return(active_rss_feed_urls)

      active_rss_feed_urls.should_receive(:where).
          with('url LIKE ?', '%www.whitehouse.gov%').
          and_return(wh_rss_feed_urls)

      active_rss_feed_urls.should_receive(:where).
          with('url LIKE ?', '%some.agency.gov%').
          and_return(basic_rss_feed_urls)
    end

    context 'when is_throttled = true' do
      it 'enqueues affiliate owned active RssFeedUrls' do
        Resque.should_receive(:enqueue_with_priority).
            with(:low, NewsItemsChecker, [rss_feed_url1.id], true)
        Resque.should_receive(:enqueue_with_priority).
            with(:low, NewsItemsChecker, [rss_feed_url2.id], true)

        RssFeedUrl.enqueue_destroy_all_news_items_with_404_by_hosts %w(www.whitehouse.gov some.agency.gov), true
      end
    end

    context 'when is_throttled = false' do
      it 'enqueues affiliate owned active RssFeedUrls' do
        Resque.should_receive(:enqueue_with_priority).
            with(:low, NewsItemsChecker, [rss_feed_url1.id], false)
        Resque.should_receive(:enqueue_with_priority).
            with(:low, NewsItemsChecker, [rss_feed_url2.id], false)

        RssFeedUrl.enqueue_destroy_all_news_items_with_404_by_hosts %w(www.whitehouse.gov some.agency.gov), false
      end
    end
  end

  describe '.unique_non_throttled_hosts' do
    it 'return unique non throttled hosts' do
      RssFeedUrl.stub_chain(:rss_feed_owned_by_affiliate, :active).
          and_return([mock_model(RssFeedUrl, url: 'http://www.whitehouse.gov/rss/1.xml'),
                      mock_model(RssFeedUrl, url: 'http://www.army.mil/rss/2.xml'),
                      mock_model(RssFeedUrl, url: 'https://www.usa.gov/rss/3.xml')])
      RssFeedUrl.unique_non_throttled_hosts.should include('www.whitehouse.gov')
      RssFeedUrl.unique_non_throttled_hosts.should include('www.usa.gov')
      RssFeedUrl.unique_non_throttled_hosts.should_not include('www.army.mil')

      RssFeedUrl.unique_non_throttled_hosts
    end
  end

  describe '#destroy_news_items_with_404' do
    it 'should enqueue RssFeedUrlItemsChecker' do
      rss_feed_url = rss_feed_urls(:white_house_blog_url)
      Resque.should_receive(:enqueue_with_priority).with(:low, NewsItemsChecker, rss_feed_url.id)
      rss_feed_url.enqueue_destroy_news_items_with_404
    end

    it 'should not freshen YoutubeProfile RssFeedUrl' do
      rss_feed_url = rss_feed_urls(:whitehouse_youtube_url)
      Resque.should_not_receive :enqueue_with_priority
      rss_feed_url.enqueue_destroy_news_items_with_404
    end
  end

  describe '#destroy_news_items' do
    it 'should enqueue RssFeedUrlItemsChecker' do
      rss_feed_url = rss_feed_urls(:white_house_blog_url)
      Resque.should_receive(:enqueue_with_priority).with(:low, NewsItemsDestroyer, rss_feed_url.id)
      rss_feed_url.enqueue_destroy_news_items
    end

    it 'should not freshen YoutubeProfile RssFeedUrl' do
      rss_feed_url = rss_feed_urls(:whitehouse_youtube_url)
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
      rss_feed_url = rss_feed_urls(:whitehouse_youtube_url)
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

  describe '#document' do
    it 'returns the rss document' do
      expect(rss_feed_url.document.class).to eq RssDocument
    end

    context 'when the url has been redirected' do
      let(:rss_feed_url) { RssFeedUrl.new(url: 'http://rss.com') }

      context 'and the redirect is arbitrary' do
        let(:new_url) { 'http://www.new.com' }

        before do
          stub_request(:get, rss_feed_url.url).to_return( body: "", status: 301, headers: { location: new_url } )
          stub_request(:get, new_url)
        end

        it 'returns nil' do
          expect(rss_feed_url.document).to be nil
        end
      end

      context 'when the redirect is for a protocol change' do
        let(:new_url) { 'https://rss.com' }

        before do
          stub_request(:get, rss_feed_url.url).to_return( body: "", status: 301, headers: { location: new_url } )
          stub_request(:get, new_url)
        end

        it 'returns the document' do
          expect(rss_feed_url.document.class).to eq RssDocument
        end
      end
    end
  end

  describe '#current_url' do
    context 'when the feed has been redirected' do
      let(:new_url) { 'http://www.new.com' }
      before do
        stub_request(:get, rss_feed_url.url).to_return( body: "", status: 301, headers: { 'Location' => new_url } )
        stub_request(:get, new_url)
      end

      it 'returns the current url' do
        expect(rss_feed_url.current_url).to eq(new_url)
      end
    end

    context 'when there is no response' do
      before do
        DocumentFetcher.stub(:fetch).with(rss_feed_url.url, an_instance_of(Hash)).
          and_return({ error: 'failed' })
      end

      it 'returns the url' do
        expect(rss_feed_url.current_url).to eq(rss_feed_url.url)
      end
    end
  end

  describe 'redirected?' do
    subject(:redirected) { rss_feed_url.redirected? }
    context 'when the url has been redirected' do
      before do
        rss_feed_url.stub(:url).and_return('http://www.new.com')
        rss_feed_url.stub(:current_url).and_return('https://www.new.com')
      end

      it { should be true }
    end

    context 'when the url has not been redirected' do
      before do
        rss_feed_url.stub(:url).and_return('http://www.new.com')
        rss_feed_url.stub(:current_url).and_return('https://www.new.com')
      end

      it 'is true' do
        expect(rss_feed_url.redirected?).to be true
      end
    end
  end

  describe '#protocol_redirect?' do
    subject(:protocol_redirect) { rss_feed_url.protocol_redirect? }
    context 'when the redirection is for a protocol change' do
      before do
        rss_feed_url.stub(:url).and_return('http://www.new.com')
        rss_feed_url.stub(:current_url).and_return('https://www.new.com')
      end

      it { should be true }
    end

    context 'when the redirection is arbitrary' do
      before do
        rss_feed_url.stub(:url).and_return('http://www.current.com')
        rss_feed_url.stub(:current_url).and_return('https://www.random.com')
      end

      it { should be false }
    end

    context 'when the url has not been redirected' do
      before do
        rss_feed_url.stub(:url).and_return('http://www.same.com')
        rss_feed_url.stub(:current_url).and_return('http://www.same.com')
      end

      it { should be false }
    end
  end
end
