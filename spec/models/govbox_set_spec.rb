require 'spec_helper'

describe GovboxSet do
  fixtures :affiliates, :agencies, :rss_feed_urls, :rss_feeds

  describe ".new(query, affiliate, geoip_info)" do
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:agency) { agencies(:irs) }
    let(:geoip_info) { mock('GeoipInfo', latitude: '12.34', longitude: '-34.56') }

    it 'should assign boosted contents' do
      affiliate.locale = 'en'
      ElasticBoostedContent.stub!(:search_for).with(q: 'foo', affiliate_id: affiliate.id, language: 'en', size: 3).and_return "BoostedContent results"
      govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
      govbox_set.boosted_contents.should == "BoostedContent results"
    end

    it 'should assign a single featured collection' do
      affiliate.locale = 'en'
      ElasticFeaturedCollection.stub!(:search_for).with(q: 'foo', affiliate_id: affiliate.id, language: 'en', size: 1).and_return "FeaturedCollection result"
      govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
      govbox_set.featured_collections.should == "FeaturedCollection result"
    end

    context 'when affiliate is agency govbox enabled' do
      before do
        affiliate.stub!(:is_agency_govbox_enabled?).and_return true
      end

      context 'when query matches an agency' do
        before do
          AgencyQuery.create!(:phrase => 'foo', :agency => agency)
        end

        it 'should assign agency' do
          govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
          govbox_set.agency.should == agency
        end
      end

      context 'when query does not match an agency' do
        it 'should assign nil agency' do
          govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
          govbox_set.agency.should be_nil
        end
      end
    end

    context 'when affiliate is not agency govbox enabled' do
      before do
        affiliate.stub!(:is_agency_govbox_enabled?).and_return false
      end

      it 'should assign nil agency' do
        govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
        govbox_set.agency.should be_nil
      end
    end

    context "when the affiliate has the jobs govbox enabled" do
      before do
        affiliate.stub!(:jobs_enabled?).and_return(true)
      end

      context "when the affiliate has a related agency with an org code" do
        before do
          affiliate.stub!(:agency).and_return(agency)
        end

        it "should call Jobs.search with the query, org code, size, hl, and lat_lon params" do
          Jobs.should_receive(:search).
            with(:query => 'foo', :hl => 1, :size => 10, :organization_id => 'ABCD', :lat_lon => '12.34,-34.56').
            and_return "jobs info"
          govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
          govbox_set.jobs.should == "jobs info"
        end
      end

      context "when the affiliate does not have a related agency with an org code" do
        it "should call Jobs.search with just the query, size, hl, and lat_lon param" do
          Jobs.should_receive(:search).with(:query => 'foo', :hl => 1, :size => 10, tags: 'federal').and_return nil
          GovboxSet.new('foo', affiliate, nil)
        end
      end
    end

    context "when the affiliate does not have the jobs govbox enabled" do
      before do
        affiliate.stub!(:jobs_enabled?).and_return(false)
      end

      it 'should assign nil jobs' do
        govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
        govbox_set.jobs.should be_nil
      end
    end

    context 'when an affiliate has news govbox enabled' do
      before do
        affiliate.should_receive(:is_rss_govbox_enabled?).and_return(true)
        affiliate.should_receive(:is_video_govbox_enabled?).and_return(false)
        news_feed = mock_model(RssFeed, name: 'News', is_managed?: false)
        blog_feed = mock_model(RssFeed, name: 'Blog', is_managed?: false)
        non_managed_feeds = [news_feed, blog_feed]
        affiliate.stub_chain(:rss_feeds, :non_mrss, :non_managed, :includes, :to_a).and_return non_managed_feeds
        @non_video_results = mock('non video results', :total => 3)
        ElasticNewsItem.should_receive(:search_for).
          with(q: 'foo', rss_feeds: [news_feed, blog_feed], excluded_urls: affiliate.excluded_urls,
               since: 13.months.ago.beginning_of_day, language: 'en').
          and_return(@non_video_results)
      end

      it 'should retrieve non-video news items from the last 13 months' do
        govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
        govbox_set.news_items.should == @non_video_results
      end
    end

    context 'when an affiliate has video govbox enabled' do
      before do
        affiliate.should_receive(:is_rss_govbox_enabled?).and_return(false)
        affiliate.should_receive(:is_video_govbox_enabled?).and_return(true)

        youtube_profile_ids = mock 'youtube profile ids'
        affiliate.should_receive(:youtube_profile_ids).and_return youtube_profile_ids
        youtube_feed = mock_model(RssFeed)
        RssFeed.stub_chain(:includes, :owned_by_youtube_profile, :where).and_return [youtube_feed]
        @video_results = mock('video results', total: 3)
        ElasticNewsItem.should_receive(:search_for).with(q: 'foo', rss_feeds: [youtube_feed],
                                                         excluded_urls: affiliate.excluded_urls, language: 'en').
          and_return(@video_results)
      end

      it 'should retrieve video news items' do
        govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
        govbox_set.video_news_items.should == @video_results
      end
    end

    context "med topics" do
      fixtures :med_topics
      context "when the affiliate has the medline govbox enabled" do

        before do
          affiliate.stub!(:is_medline_govbox_enabled?).and_return true
        end

        context "when the search matches a MedTopic record" do
          it "should retrieve the associated Med Topic record" do
            govbox_set = GovboxSet.new('ulcerative colitis', affiliate, geoip_info)
            govbox_set.med_topic.should == med_topics(:ulcerative_colitis)
          end

          context "when the locale is not the default" do
            before do
              I18n.locale = :es
            end

            it "should retrieve the spanish version of the med topic" do
              govbox_set = GovboxSet.new('Colitis ulcerativa', affiliate, geoip_info)
              govbox_set.med_topic.should == med_topics(:ulcerative_colitis_es)
            end

            after do
              I18n.locale = I18n.default_locale
            end
          end

        end

        context "when the query does not match a med topic" do
          it "should not set the med topic" do
            govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
            govbox_set.med_topic.should be_nil
          end
        end
      end

      context "when the affiliate does not have the medline govbox enabled" do
        before do
          affiliate.stub!(:is_medline_govbox_enabled?).and_return false
        end

        it "should not set the med topic" do
          govbox_set = GovboxSet.new('ulcerative colitis', affiliate, geoip_info)
          govbox_set.med_topic.should be_nil
        end
      end
    end

    describe "twitter" do
      context "when affiliate is twitter govbox enabled" do
        before do
          Twitter.stub!(:user).and_return mock('Twitter')
        end

        context "when affiliate has Twitter Profiles" do
          before do
            affiliate.twitter_profiles.create!(:screen_name => 'USASearch',
                                               :name => 'Test',
                                               :twitter_id => 123,
                                               :profile_image_url => 'http://a0.twimg.com/profile_images/1879738641/USASearch_avatar_normal.png')
          end

          it "should find the most recent relevant tweet" do
            ElasticTweet.should_receive(:search_for).with(q: 'foo', twitter_profile_ids: [123], since: 3.days.ago.beginning_of_day, language: "en", size: 1).and_return 'Twitter stuff'
            govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
            govbox_set.tweets.should == 'Twitter stuff'
          end
        end

        context "when affiliate has no Twitter Profiles" do
          it "should not set tweets" do
            govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
            govbox_set.tweets.should be_nil
          end
        end

      end
    end

    describe "photos" do
      before do
        FlickrPhoto.stub!(:search_for).with('foo', affiliate).and_return "FlickrPhoto results"
      end

      context "when the affiliate has photo govbox enabled" do
        before do
          affiliate.update_attributes(:is_photo_govbox_enabled => true)
        end

        it "should find relevant photos" do
          govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
          govbox_set.photos.should == "FlickrPhoto results"
        end
      end

      context "when the affiliate does not have photo govbox enabled" do
        before do
          affiliate.update_attributes(:is_photo_govbox_enabled => false)
        end

        it "should not search for Flickr Photos" do
          govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
          govbox_set.photos.should be_nil
        end
      end
    end

    it 'should assign related searches' do
      SaytSuggestion.stub!(:related_search).with('foo', affiliate).and_return "related search results"
      govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
      govbox_set.related_search.should == "related search results"
    end
  end
end
