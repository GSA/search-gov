require 'spec_helper'

describe SiteAutodiscoverer do
  let(:site) { mock_model(Affiliate) }
  let(:autodiscoverer) { SiteAutodiscoverer.new(site) }

  describe '#run' do
    context 'when domain contains valid hostname' do
      let(:domain) { 'usasearch.howto.gov/with-path' }
      let(:url) { "http://#{domain}" }

      before do
        site.stub_chain(:site_domains, :pluck).and_return([domain])
        site.stub_chain(:site_domains, :size).and_return(1)
        DocumentFetcher.should_receive(:fetch).
            with(url).
            and_return({ last_effective_url: url, body: '' })
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
        site.stub_chain(:site_domains, :pluck).and_return([domain])
        site.stub_chain(:site_domains, :size).and_return(1)
        DocumentFetcher.should_receive(:fetch).with('http://howto.gov').and_return({})
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

      let(:updated_url) { "https://www.#{domain}" }
      let(:response) { { body: '', status: '301 Moved Permanently', last_effective_url: updated_url } }

      before do
        site.stub_chain(:site_domains, :pluck).and_return([domain])
        site.stub_chain(:site_domains, :size).and_return(1)
        DocumentFetcher.should_receive(:fetch).with(url).and_return(response)
      end

      it 'should update website with the last effective URL' do
        site.should_receive(:update_attributes!).with(website: updated_url)
        autodiscoverer.should_receive(:autodiscover_website_contents)
        autodiscoverer.run
      end
    end

    context 'when domain does not contain a valid hostname' do
      let(:domain) { '.gov' }

      before do
        site.stub_chain(:site_domains, :pluck).and_return([domain])
        site.stub_chain(:site_domains, :size).and_return(1)
        DocumentFetcher.should_receive(:fetch).with('http://.gov').and_return({})
        DocumentFetcher.should_receive(:fetch).with('http://www..gov').and_return({})
      end

      it 'should not update website' do
        site.should_not_receive(:update_attributes!)
        autodiscoverer.should_not_receive(:autodiscover_website_contents)
        autodiscoverer.run
      end
    end
  end

  describe '#autodiscover_favicon_url' do
    let(:domain) { 'usa.gov' }
    before do
      site.stub_chain(:site_domains, :pluck).and_return([domain])
      site.stub_chain(:site_domains, :size).and_return(1)
      site.stub(:website).and_return('http://usa.gov')
    end

    context 'when the favicon link is an absolute path' do
      before do
        page_with_favicon = Rails.root.join('spec/fixtures/html/home_page_with_icon_link.html').read
        DocumentFetcher.should_receive(:fetch).with('http://usa.gov').and_return({ body: page_with_favicon })
      end

      it "should update the affiliate's favicon_url attribute with the value" do
        site.should_receive(:update_attributes!).
            with(favicon_url: 'http://usa.gov/resources/images/usa_favicon.gif')
        autodiscoverer.autodiscover_favicon_url
      end
    end

    context 'when the favicon link is a relative path' do
      before do
        page_with_favicon = Rails.root.join('spec/fixtures/html/home_page_with_relative_icon_link.html').read
        DocumentFetcher.should_receive(:fetch).with('http://usa.gov').and_return({ body: page_with_favicon })
      end

      it 'should store a full url as the favicon link' do
        site.should_receive(:update_attributes!).
            with(favicon_url: 'http://usa.gov/resources/images/usa_favicon.gif')
        autodiscoverer.autodiscover_favicon_url
      end
    end

    context 'when default favicon.ico exists' do
      it "should update the affiliate's favicon_url attribute" do
        page_with_no_links = Rails.root.join('spec/fixtures/html/page_with_no_links.html').read
        DocumentFetcher.should_receive(:fetch).with('http://usa.gov').and_return( { body: page_with_no_links })

        autodiscoverer.should_receive(:open).
            with('http://usa.gov/favicon.ico').
            and_return File.read("#{Rails.root}/spec/fixtures/ico/favicon.ico")

        site.should_receive(:update_attributes!).
            with(favicon_url: 'http://usa.gov/favicon.ico')

        autodiscoverer.autodiscover_favicon_url
      end
    end

    context 'when default favicon.ico does not exist' do
      it "should not update the affiliate's favicon_url attribute" do
        page_with_no_links = Rails.root.join('spec/fixtures/html/page_with_no_links.html').read
        DocumentFetcher.should_receive(:fetch).with('http://usa.gov').and_return( { body: page_with_no_links })

        autodiscoverer.should_receive(:open).
            with('http://usa.gov/favicon.ico').
            and_raise('Some Exception')
        site.should_not_receive(:update_attributes!)

        autodiscoverer.autodiscover_favicon_url
      end
    end

    context 'when something goes horribly wrong' do
      it 'should log an error' do
        DocumentFetcher.should_receive(:fetch).with('http://usa.gov').and_return({})

        Rails.logger.should_receive(:error).with(/Error when autodiscovering favicon/)
        autodiscoverer.autodiscover_favicon_url
      end
    end
  end

  describe '#autodiscover_rss_feeds' do
    let(:domain) { 'usa.gov' }
    before do
      site.stub_chain(:site_domains, :pluck).and_return([domain])
      site.stub_chain(:site_domains, :size).and_return(1)
      site.stub(:website).and_return('http://usa.gov')
    end

    context 'when the home page has alternate links to an rss feed' do
      before do
        doc = Rails.root.join('spec/fixtures/html/autodiscovered_page.html').read
        DocumentFetcher.should_receive(:fetch).with('http://usa.gov').and_return({ body: doc })
      end

      it 'should create new rss feeds' do
        new_rss_feed_url = mock(RssFeedUrl, new_record?: true, url: 'http://www.usa.gov/rss/updates.xml')
        existing_rss_feed_url = mock(RssFeedUrl, new_record?: false, url: 'http://www.usa.gov/rss/FAQs.xml')
        RssFeedUrl.stub_chain(:rss_feed_owned_by_affiliate, :find_existing_or_initialize).
            and_return(new_rss_feed_url, existing_rss_feed_url)

        rss_feed_1 = mock_model(RssFeed)
        rss_feed_1.stub_chain(:rss_feed_urls, :build)
        rss_feed_1.should_receive(:save)
        rss_feed_2 = mock_model(RssFeed)
        rss_feed_2.should_receive(:rss_feed_urls=).with([existing_rss_feed_url])
        rss_feed_2.should_receive(:save)
        site.stub_chain(:rss_feeds, :build).and_return(rss_feed_1, rss_feed_2)

        autodiscoverer.autodiscover_rss_feeds
      end
    end

    context 'when something goes horribly wrong' do
      before do
        autodiscoverer.should_receive(:site_valid_for_autodiscovery?).and_return(true)
        DocumentFetcher.should_receive(:fetch).with('http://usa.gov').and_return({})
      end

      it 'should log an error' do
        Rails.logger.should_receive(:error).with(/Error when autodiscovering rss feeds/)
        autodiscoverer.autodiscover_rss_feeds
      end
    end
  end

  describe '#autodiscover_social_media' do
    let(:domain) { 'usa.gov' }

    before do
      site.stub_chain(:site_domains, :pluck).and_return([domain])
      site.stub_chain(:site_domains, :size).and_return(1)
      site.stub(:website).and_return('http://usa.gov')
    end

    context 'when the page has social media links' do
      before do
        page_with_social_media_urls = Rails.root.join('spec/fixtures/html/home_page_with_social_media_urls.html').read
        DocumentFetcher.should_receive(:fetch).with('http://usa.gov').and_return({ body: page_with_social_media_urls })
        Rails.logger.should_not_receive(:error)
      end

      it 'should create flickr profile' do
        InstagramData.stub(:import_profile) { nil }
        TwitterData.stub(:import_profile) { nil }
        YoutubeData.stub(:import_profile) { nil }

        flickr_profiles = mock('flickr profiles')
        site.should_receive(:flickr_profiles).and_return(flickr_profiles)
        flickr_profiles.
            should_receive(:create).
            with(url: 'http://flickr.com/photos/whitehouse')

        autodiscoverer.autodiscover_social_media
      end

      it 'creates instagram profile' do
        site.stub_chain(:flickr_profiles, :create)
        TwitterData.stub(:import_profile) { nil }
        YoutubeData.stub(:import_profile) { nil }

        instagram_profile = mock_model(InstagramProfile)
        InstagramData.should_receive(:import_profile).with('whitehouse').and_return(instagram_profile)

        instagram_profiles = mock('instagram profiles')
        site.stub(:instagram_profiles) { instagram_profiles }

        instagram_profiles.should_receive(:exists?).with(instagram_profile).and_return(false)
        instagram_profiles.should_receive(:<<).with(instagram_profile)

        autodiscoverer.autodiscover_social_media
      end

      it 'should create twitter profile' do
        site.stub_chain(:flickr_profiles, :create)
        InstagramData.stub(:import_profile) { nil }
        YoutubeData.stub(:import_profile) { nil }

        twitter_profile = mock_model(TwitterProfile)
        TwitterData.should_receive(:import_profile).
            with('whitehouse').
            and_return(twitter_profile)

        site.stub_chain(:twitter_profiles, :exists?).and_return(false)
        twitter_settings = mock('twitter_settings')
        site.should_receive(:affiliate_twitter_settings).and_return(twitter_settings)
        twitter_settings.should_receive(:create).with(twitter_profile_id: twitter_profile.id)

        autodiscoverer.autodiscover_social_media
      end

      it 'should create youtube profile' do
        site.stub_chain(:flickr_profiles, :create)
        InstagramData.stub(:import_profile) { nil }
        TwitterData.stub(:import_profile) { nil }

        youtube_profile = mock_model(YoutubeProfile)
        YoutubeData.stub(:import_profile) { youtube_profile }

        youtube_profiles = mock('youtube profiles')
        site.stub(:youtube_profiles).and_return(youtube_profiles)
        youtube_profiles.should_receive(:exists?).with(youtube_profile).and_return(false)
        youtube_profiles.should_receive(:<<).with(youtube_profile)
        site.should_receive(:enable_video_govbox!)

        autodiscoverer.autodiscover_social_media
      end
    end

    context 'when something goes horribly wrong' do
      before do
        autodiscoverer.should_receive(:site_valid_for_autodiscovery?).and_return(true)
        DocumentFetcher.should_receive(:fetch).with('http://usa.gov').and_return({})
      end

      it 'should log an error' do
        Rails.logger.should_receive(:error).with(/Error when autodiscovering social media/)
        autodiscoverer.autodiscover_social_media
      end
    end
  end
end
