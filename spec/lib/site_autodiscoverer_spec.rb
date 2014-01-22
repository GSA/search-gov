require 'spec_helper'

describe SiteAutodiscoverer do
  let(:site) { mock_model(Affiliate) }
  let(:autodiscoverer) { SiteAutodiscoverer.new(site) }

  describe '#run' do
    context 'when domain contains valid hostname' do
      let(:domain) { 'usasearch.howto.gov/with-path' }
      let(:tempfile) { mock('tempfile') }

      before do
        site.stub_chain(:site_domains, :pluck).and_return([domain])
        site.stub_chain(:site_domains, :size).and_return(1)
        autodiscoverer.should_receive(:open).
            with('http://usasearch.howto.gov/with-path').
            and_return(tempfile)
      end

      it 'should update website' do
        site.should_receive(:update_attributes!).with(
            website: 'http://usasearch.howto.gov/with-path')
        autodiscoverer.should_receive(:autodiscover_website_contents)
        autodiscoverer.run
      end
    end

    context 'when valid hostname require www. prefix' do
      let(:domain) { 'howto.gov' }
      let(:tempfile) { mock('tempfile') }

      before do
        site.stub_chain(:site_domains, :pluck).and_return([domain])
        site.stub_chain(:site_domains, :size).and_return(1)
        autodiscoverer.should_receive(:open).with('http://howto.gov').and_raise
        autodiscoverer.should_receive(:open).with('http://www.howto.gov').and_return(tempfile)
      end

      it 'should update website' do
        site.should_receive(:update_attributes!).with(
            website: 'http://www.howto.gov')
        autodiscoverer.should_receive(:autodiscover_website_contents)
        autodiscoverer.run
      end
    end

    context 'when domain does not contain a valid hostname' do
      let(:domain) { '.gov' }

      before do
        site.stub_chain(:site_domains, :pluck).and_return([domain])
        site.stub_chain(:site_domains, :size).and_return(1)
        autodiscoverer.should_receive(:open).with('http://.gov').and_raise
        autodiscoverer.should_receive(:open).with('http://www..gov').and_raise
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
        page_with_favicon = File.open("#{Rails.root}/spec/fixtures/html/home_page_with_icon_link.html")
        autodiscoverer.should_receive(:open).and_return(page_with_favicon)
      end

      it "should update the affiliate's favicon_url attribute with the value" do
        site.should_receive(:update_attributes!).
            with(favicon_url: 'http://usa.gov/resources/images/usa_favicon.gif')
        autodiscoverer.autodiscover_favicon_url
      end
    end

    context 'when the favicon link is a relative path' do
      before do
        page_with_favicon = File.open("#{Rails.root}/spec/fixtures/html/home_page_with_relative_icon_link.html")
        autodiscoverer.should_receive(:open).and_return(page_with_favicon)
      end

      it 'should store a full url as the favicon link' do
        site.should_receive(:update_attributes!).
            with(favicon_url: 'http://usa.gov/resources/images/usa_favicon.gif')
        autodiscoverer.autodiscover_favicon_url
      end
    end

    context 'when default favicon.ico exists' do
      it "should update the affiliate's favicon_url attribute" do
        autodiscoverer.should_receive(:open).
            with('http://usa.gov').
            and_return File.read("#{Rails.root}/spec/fixtures/html/page_with_no_links.html")
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
        autodiscoverer.should_receive(:open).
            with('http://usa.gov').
            and_return File.read("#{Rails.root}/spec/fixtures/html/page_with_no_links.html")
        autodiscoverer.should_receive(:open).
            with('http://usa.gov/favicon.ico').
            and_raise('Some Exception')
        site.should_not_receive(:update_attributes!)

        autodiscoverer.autodiscover_favicon_url
      end
    end

    context 'when something goes horribly wrong' do
      before { autodiscoverer.should_receive(:open).and_raise 'Some Exception' }

      it 'should log an error' do
        Rails.logger.should_receive(:error).with("Error when autodiscovering favicon for #{site.name}: Some Exception")
        autodiscoverer.autodiscover_favicon_url
      end
    end
  end

  describe '#autodiscover_rss_feeds' do
    let(:domain) { 'usa.gov' }
    before do
      site.stub_chain(:site_domains, :pluck).and_return([domain])
      site.stub_chain(:site_domains, :size).and_return(1)
    end

    context 'when the home page has alternate links to an rss feed' do
      before do
        site.stub(:website).and_return('http://usa.gov')
        doc = File.read "#{Rails.root}/spec/fixtures/html/autodiscovered_page.html"
        autodiscoverer.should_receive(:open).at_least(:once).with('http://usa.gov').and_return doc
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
        autodiscoverer.should_receive(:open).and_raise 'Some Exception'
      end

      it 'should log an error' do
        Rails.logger.should_receive(:error).with("Error when autodiscovering rss feeds for #{site.name}: Some Exception")
        autodiscoverer.autodiscover_rss_feeds
      end
    end
  end

  describe '#autodiscover_social_media' do
    let(:domain) { 'usa.gov' }

    before do
      site.stub_chain(:site_domains, :pluck).and_return([domain])
      site.stub_chain(:site_domains, :size).and_return(1)
    end

    context 'when the page has social media links' do
      before do
        autodiscoverer.should_receive(:site_valid_for_autodiscovery?).and_return(true)
        page_with_social_media_urls = File.open("#{Rails.root}/spec/fixtures/html/home_page_with_social_media_urls.html")
        autodiscoverer.should_receive(:open).and_return(page_with_social_media_urls)
      end

      it 'should create flickr profile' do
        TwitterClient.stub_chain(:instance, :user) { nil }
        YoutubeProfile.stub_chain(:where, :first_or_initialize).
            and_return(mock_model(YoutubeProfile, save: false))

        flickr_profiles = mock('flickr profiles')
        site.should_receive(:flickr_profiles).and_return(flickr_profiles)
        flickr_profiles.
            should_receive(:create).
            with(url: 'http://flickr.com/photos/whitehouse')

        autodiscoverer.autodiscover_social_media
      end

      it 'should create twitter profile' do
        site.stub_chain(:flickr_profiles, :create)
        YoutubeProfile.stub_chain(:where, :first_or_initialize).
            and_return(mock_model(YoutubeProfile, save: false))

        twitter_user = mock('twitter user', screen_name: 'USASsearch')
        TwitterClient.stub_chain(:instance, :user) { twitter_user }

        twitter_profile = mock_model(TwitterProfile)
        TwitterData.should_receive(:import_profile).
            with(twitter_user).
            and_return(twitter_profile)

        site.stub_chain(:twitter_profiles, :exists?).and_return(false)
        twitter_settings = mock('twitter_settings')
        site.should_receive(:affiliate_twitter_settings).and_return(twitter_settings)
        twitter_settings.should_receive(:create).with(twitter_profile: twitter_profile)

        autodiscoverer.autodiscover_social_media
      end

      it 'should create youtube profile' do
        site.stub_chain(:flickr_profiles, :create)
        TwitterClient.stub_chain(:instance, :user) { nil }

        youtube_profile = mock_model(YoutubeProfile, new_record?: true)
        YoutubeProfile.stub_chain(:where, :first_or_initialize).
            and_return(youtube_profile)
        youtube_profile.should_receive(:save).and_return(true)

        youtube_profiles = mock('youtube profiles')
        site.stub(:youtube_profiles).and_return(youtube_profiles)
        youtube_profiles.should_receive(:<<).with(youtube_profile)
        site.should_receive(:enable_video_govbox!)

        autodiscoverer.autodiscover_social_media
      end
    end

    context 'when something goes horribly wrong' do
      before do
        autodiscoverer.should_receive(:site_valid_for_autodiscovery?).and_return(true)
        autodiscoverer.should_receive(:open).and_raise 'Some Exception'
      end

      it 'should log an error' do
        Rails.logger.should_receive(:error).with("Error when autodiscovering social media for #{site.name}: Some Exception")
        autodiscoverer.autodiscover_social_media
      end
    end
  end
end
