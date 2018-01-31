require 'spec_helper'

describe SiteAutodiscoverer do
  let(:site) { mock_model(Affiliate) }
  let(:autodiscoverer) { SiteAutodiscoverer.new(site, autodiscovery_url) }
  let(:autodiscovery_url) { nil }

  describe '#initialize' do
    context 'when autodiscovery_url is not present' do
      it 'should initialize correctly' do
        autodiscoverer.should be_kind_of(SiteAutodiscoverer)
      end
    end

    context 'when autodiscovery_url is present and valid' do
      let(:autodiscovery_url) { 'https://www.usa.gov' }

      it 'should initialize correctly' do
        autodiscoverer.should be_kind_of(SiteAutodiscoverer)
      end
    end

    context 'when the autodiscovery_url is present but invalid' do
      let(:autodiscovery_url) { 'Four score and seven years ago' }

      it 'should raise an error' do
        -> { autodiscoverer }.should raise_error(URI::InvalidURIError)
      end
    end
  end

  describe '#autodiscovery_url' do
    subject { autodiscoverer.autodiscovery_url }
    context 'when no autodiscovery_url is provided to the constructor' do
      context 'when the site has no default_autodiscovery_url' do
        before do
          site.stub(:default_autodiscovery_url) { nil }
        end

        it 'has no autodiscovery_url' do
          subject.should be_nil
        end
      end

      context 'when the site has a default_autodiscovery_url' do
        let(:url) { 'https://www.usa.gov' }
        before do
          site.stub(:default_autodiscovery_url) { url }
          autodiscoverer.stub(:autodiscover_website).with(url).and_return(url)
        end

        it "should verify the site's default_autodiscovery_url" do
          subject.should eq(url)
        end

        context 'when the autodiscover_website returns a different url' do
          let(:other_url) { 'https://www.usa.gov' }
          before do
            autodiscoverer.stub(:autodiscover_website).with(url).and_return(other_url)
          end

          it "should use the site's alternative, autodiscovered url" do
            subject.should eq(other_url)
          end
        end
      end
    end

    context 'when an autodiscovery_url is provided to the constructuro' do
      let(:autodiscovery_url) { 'https://www.usa.gov' }

      it 'should remember the provided autodiscovery_url' do
        subject.should eq(autodiscovery_url)
      end
    end
  end

  describe '#autodiscover_website' do
    subject { described_class.new(site).autodiscover_website(base_url) }

    context 'when base_url is nil' do
      let(:base_url) { nil }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end

  describe '#autodiscover_website_contents' do
    let(:autodiscoverer) { described_class.new(site) }

    before do
      autodiscoverer.should_receive(:autodiscover_favicon_url)
      autodiscoverer.should_receive(:autodiscover_rss_feeds)
      autodiscoverer.should_receive(:autodiscover_social_media)
    end

    it 'calls the expected methods' do
      autodiscoverer.autodiscover_website_contents
    end
  end

  describe '#run' do
    context 'when domain contains valid hostname' do
      let(:domain) { 'usasearch.howto.gov/with-path' }
      let(:url) { "https://#{domain}" }

      before do
        site.stub(:default_autodiscovery_url).and_return(url)
        DocumentFetcher.should_receive(:fetch)
          .with(url)
          .and_return(last_effective_url: url, body: '')
      end

      it 'should update website' do
        site.should_receive(:update_attributes!).with(website: url)
        autodiscoverer.should_receive(:autodiscover_website_contents)
        autodiscoverer.run
      end
    end

    context 'when valid hostname require www. prefix' do
      let(:domain) { 'howto.gov' }
      let(:url) { 'http://www.howto.gov' }
      let(:response) { { body: '', last_effective_url: url, status: '301 Moved Permanently' } }

      before do
        site.stub(:default_autodiscovery_url).and_return("http://#{domain}")
        DocumentFetcher.should_receive(:fetch).with("http://#{domain}").and_return({})
        DocumentFetcher.should_receive(:fetch).with(url).and_return(response)
      end

      it 'should update website' do
        site.should_receive(:update_attributes!).with(website: url)
        autodiscoverer.should_receive(:autodiscover_website_contents)
        autodiscoverer.run
      end
    end

    context 'when website response status code is 301' do
      let(:domain) { 'howto.gov' }
      let(:url) { "http://#{domain}" }

      let(:updated_url) { "http://www.#{domain}" }
      let(:response) { { body: '', status: '301 Moved Permanently', last_effective_url: updated_url } }

      before do
        site.stub(:default_autodiscovery_url).and_return(url)
        DocumentFetcher.should_receive(:fetch).with(url).and_return(response)
      end

      it 'should update website with the last effective URL' do
        site.should_receive(:update_attributes!).with(website: updated_url)
        autodiscoverer.should_receive(:autodiscover_website_contents)
        autodiscoverer.run
      end
    end
  end

  describe '#autodiscover_favicon_url' do
    let(:domain) { 'www.usa.gov' }
    let(:url) { "https://#{domain}" }
    let(:autodiscovery_url) { url }

    context 'when the favicon link is an absolute path' do
      before do
        page_with_favicon = Rails.root.join('spec/fixtures/html/home_page_with_icon_link.html').read
        DocumentFetcher.should_receive(:fetch).with(url).and_return(body: page_with_favicon)
      end

      it "should update the affiliate's favicon_url attribute with the value" do
        site.should_receive(:update_attributes!)
          .with(favicon_url: 'https://www.usa.gov/resources/images/usa_favicon.gif')
        autodiscoverer.autodiscover_favicon_url
      end
    end

    context 'when the favicon link is a relative path' do
      before do
        page_with_favicon = Rails.root.join('spec/fixtures/html/home_page_with_relative_icon_link.html').read
        DocumentFetcher.should_receive(:fetch).with(url).and_return(body: page_with_favicon)
      end

      it 'should store a full url as the favicon link' do
        site.should_receive(:update_attributes!)
          .with(favicon_url: 'https://www.usa.gov/resources/images/usa_favicon.gif')
        autodiscoverer.autodiscover_favicon_url
      end
    end

    context 'when default favicon.ico exists' do
      it "should update the affiliate's favicon_url attribute" do
        page_with_no_links = Rails.root.join('spec/fixtures/html/page_with_no_links.html').read
        DocumentFetcher.should_receive(:fetch).with(url).and_return(body: page_with_no_links)

        autodiscoverer.should_receive(:open)
          .with('https://www.usa.gov/favicon.ico')
          .and_return File.read("#{Rails.root}/spec/fixtures/ico/favicon.ico")

        site.should_receive(:update_attributes!)
          .with(favicon_url: 'https://www.usa.gov/favicon.ico')

        autodiscoverer.autodiscover_favicon_url
      end
    end

    context 'when default favicon.ico does not exist' do
      it "should not update the affiliate's favicon_url attribute" do
        page_with_no_links = Rails.root.join('spec/fixtures/html/page_with_no_links.html').read
        DocumentFetcher.should_receive(:fetch).with(url).and_return(body: page_with_no_links)

        autodiscoverer.should_receive(:open)
          .with('https://www.usa.gov/favicon.ico')
          .and_raise('Some Exception')
        site.should_not_receive(:update_attributes!)

        autodiscoverer.autodiscover_favicon_url
      end
    end

    context 'when something goes horribly wrong' do
      it 'should log an error' do
        DocumentFetcher.should_receive(:fetch).with('https://www.usa.gov').and_return({})

        Rails.logger.should_receive(:error).with(/Error when autodiscovering favicon/)
        autodiscoverer.autodiscover_favicon_url
      end
    end
  end

  describe '#autodiscover_rss_feeds' do
    let(:domain) { 'www.usa.gov' }
    let(:url) { "https://#{domain}" }
    let(:autodiscovery_url) { url }

    context 'when the home page has alternate links to an rss feed' do
      before do
        doc = Rails.root.join('spec/fixtures/html/autodiscovered_page.html').read
        DocumentFetcher.should_receive(:fetch).with(url).and_return(body: doc)
      end

      it 'should create new rss feeds' do
        new_rss_feed_url = double(RssFeedUrl, new_record?: true, save: true, url: 'https://www.usa.gov/rss/updates.xml')
        new_rss_feed = double(RssFeed, new_record?: true, save!: true, name: 'USA.gov Updates: News and Features')
        existing_rss_feed_url = double(RssFeedUrl, new_record?: false, save: true, url: 'https://www.usa.gov/rss/FAQs.xml')
        existing_rss_feed = double(RssFeed, new_record?: false, save!: true, name: 'Popular Government Questions from USA.gov')
        RssFeedUrl.stub_chain(:rss_feed_owned_by_affiliate, :find_existing_or_initialize)
          .and_return(new_rss_feed_url, existing_rss_feed_url)

        site.stub_chain(:rss_feeds, :<<).with(new_rss_feed)
        new_rss_feed.stub_chain(:rss_feed_urls, :build)
        existing_rss_feed.should_receive(:rss_feed_urls=).with([existing_rss_feed_url])
        site.stub_chain(:rss_feeds, :find_existing_or_initialize)
            .with(new_rss_feed.name, new_rss_feed_url.url)
            .and_return(new_rss_feed)
        site.stub_chain(:rss_feeds, :find_existing_or_initialize)
            .with(existing_rss_feed.name, existing_rss_feed_url.url)
            .and_return(existing_rss_feed)

        autodiscoverer.autodiscover_rss_feeds
      end
    end

    context 'when something goes horribly wrong' do
      before do
        DocumentFetcher.should_receive(:fetch).with(url).and_return({})
      end

      it 'should log an error' do
        Rails.logger.should_receive(:error).with(/Error when autodiscovering rss feeds/)
        autodiscoverer.autodiscover_rss_feeds
      end
    end
  end

  describe '#autodiscover_social_media' do
    let(:domain) { 'www.usa.gov' }
    let(:url) { "https://#{domain}" }
    let(:autodiscovery_url) { url }
    let(:flickr_data) { double(FlickrData, import_profile: nil, new_profile_created?: true) }

    context 'when the page has social media links' do
      before do
        page_with_social_media_urls = Rails.root.join('spec/fixtures/html/home_page_with_social_media_urls.html').read
        DocumentFetcher.should_receive(:fetch).with(url).and_return(body: page_with_social_media_urls)
        Rails.logger.should_not_receive(:error)
        FlickrData.stub(:new).with(site, 'http://flickr.com/photos/whitehouse').and_return(flickr_data)
      end

      it 'should create flickr profile' do
        TwitterData.stub(:import_profile)
        YoutubeProfileData.stub(:import_profile)

        flickr_data.should_receive(:import_profile)
        flickr_data.should_receive(:new_profile_created?).and_return true

        autodiscoverer.autodiscover_social_media
      end

      it 'should create twitter profile' do
        YoutubeProfileData.stub(:import_profile)

        twitter_profile = mock_model(TwitterProfile)
        TwitterData.should_receive(:import_profile)
          .with('whitehouse')
          .and_return(twitter_profile)

        site.stub_chain(:twitter_profiles, :exists?).and_return(false)
        twitter_settings = double('twitter_settings')
        site.should_receive(:affiliate_twitter_settings).and_return(twitter_settings)
        twitter_settings.should_receive(:create).with(twitter_profile_id: twitter_profile.id)

        autodiscoverer.autodiscover_social_media
      end

      it 'should create youtube profile' do
        TwitterData.stub(:import_profile)

        youtube_profile = mock_model(YoutubeProfile)
        YoutubeProfileData.stub(:import_profile) do |url|
          youtube_profile if 'http://www.youtube.com/whitehouse1?watch=0' == url
        end

        youtube_profiles = double('youtube profiles')
        site.stub(:youtube_profiles).and_return(youtube_profiles)
        youtube_profiles.should_receive(:exists?).with(youtube_profile).and_return(false)
        youtube_profiles.should_receive(:<<).with(youtube_profile)
        site.should_receive(:enable_video_govbox!).once

        autodiscoverer.autodiscover_social_media
      end
    end

    context 'when the home page has malformed social media URLs' do
      before do
        FlickrProfile.delete_all
        page_with_bad_social_media_urls = Rails.root.join('spec/fixtures/html/home_page_with_bad_social_media_urls.html').read
        DocumentFetcher.should_receive(:fetch).with('https://www.usa.gov').and_return(body: page_with_bad_social_media_urls)
      end

      it 'should not create the feed' do
        autodiscoverer.autodiscover_social_media
        FlickrProfile.count.should be_zero
      end
    end

    context 'when something goes horribly wrong' do
      before do
        DocumentFetcher.should_receive(:fetch).with('https://www.usa.gov').and_return({})
      end

      it 'should log an error' do
        Rails.logger.should_receive(:error).with(/Error when autodiscovering social media/)
        autodiscoverer.autodiscover_social_media
      end
    end
  end
end
