require 'spec_helper'

describe GovboxSet do
  fixtures :affiliates, :agencies, :federal_register_agencies, :rss_feed_urls, :rss_feeds

  describe ".new(query, affiliate, geoip_info)" do
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:agency) { agencies(:irs) }
    let(:geoip_info) { mock('GeoipInfo', latitude: '12.34', longitude: '-34.56') }
    let(:highlight_options) do
      { highlighting: true,
        pre_tags: '<b>',
        post_tags: '</b>' }.freeze
    end

    context 'when the affiliate has boosted contents' do
      it 'should assign boosted contents' do
        affiliate.locale = 'en'
        expected_results = mock(ElasticBoostedContentResults, total: 1)
        ElasticBoostedContent.stub!(:search_for).with(q: 'foo', affiliate_id: affiliate.id, language: 'en', size: 3).and_return(expected_results)
        govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
        govbox_set.boosted_contents.should == expected_results
        expect(govbox_set.modules).to include('BOOS')
      end

      it 'uses highlight options' do
        expected_search_options = {
          affiliate_id: affiliate.id,
          language: 'en',
          q: 'foo',
          size: 3
        }.merge(highlight_options)

        expected_results = mock(ElasticBoostedContentResults, total: 1)
        ElasticBoostedContent.should_receive(:search_for).with(expected_search_options).
          and_return(expected_results)
        govbox_set = GovboxSet.new('foo', affiliate, geoip_info, highlight_options)
        govbox_set.boosted_contents.should == expected_results
      end
    end

    context 'when the affiliate has featured collections' do
      it 'should assign a single featured collection' do
        affiliate.locale = 'en'
        expected_results = mock(ElasticFeaturedCollectionResults, total: 1)
        ElasticFeaturedCollection.stub!(:search_for).with(q: 'foo', affiliate_id: affiliate.id, language: 'en', size: 1).and_return(expected_results)
        govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
        govbox_set.featured_collections.should == expected_results
        expect(govbox_set.modules).to include('BBG')
      end

      it 'uses highlight options' do
        expected_search_options = {
          affiliate_id: affiliate.id,
          language: 'en',
          q: 'foo',
          size: 1
        }.merge(highlight_options)

        expected_results = mock(ElasticFeaturedCollectionResults, total: 1)
        ElasticFeaturedCollection.stub!(:search_for).with(expected_search_options).
          and_return(expected_results)
        govbox_set = GovboxSet.new('foo', affiliate, geoip_info, highlight_options)
        govbox_set.featured_collections.should == expected_results
      end
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

    context 'when affiliate has an agency and the federal register document govbox enabled' do
      let(:agency) { agencies(:irs) }
      let(:federal_register_agency) { federal_register_agencies(:fr_irs) }

      before do
        affiliate.stub(:agency).and_return(agency)
        affiliate.should_receive(:is_federal_register_document_govbox_enabled?).and_return(true)
      end

      it 'searches for federal register documents' do
        expected_results = mock(ElasticFeaturedCollectionResults, total: 1)
        ElasticFederalRegisterDocument.should_receive(:search_for).
          with(hash_including(federal_register_agency_ids: [federal_register_agency.id],
                              language: 'en',
                              q: 'foo')).
          and_return(expected_results)

        govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
        govbox_set.federal_register_documents.should == expected_results
        expect(govbox_set.modules).to include('FRDOC')
      end

      it 'uses highlight options' do
        expected_results = mock(ElasticFeaturedCollectionResults, total: 1)
        expected_search_options = {
          federal_register_agency_ids: [federal_register_agency.id],
          language: 'en',
          q: 'foo'
        }.merge(highlight_options)

        ElasticFederalRegisterDocument.should_receive(:search_for).
          with(expected_search_options).
          and_return(expected_results)

        govbox_set = GovboxSet.new('foo', affiliate, geoip_info, highlight_options)
        govbox_set.federal_register_documents.should == expected_results
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
          expect(govbox_set.modules).to include('JOBS')
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
      let(:blog_feed) { mock_model(RssFeed, name: 'Blog', is_managed?: false) }
      let(:news_feed) { mock_model(RssFeed, name: 'News', is_managed?: false) }
      let(:non_video_results) { mock('non video results', :total => 3) }

      before do
        affiliate.should_receive(:is_rss_govbox_enabled?).and_return(true)
        affiliate.should_receive(:is_video_govbox_enabled?).and_return(false)
        non_managed_feeds = [news_feed, blog_feed]
        affiliate.stub_chain(:rss_feeds, :non_mrss, :non_managed, :includes, :to_a).and_return non_managed_feeds
      end

      it 'should retrieve non-video news items from the last 13 months' do
        ElasticNewsItem.should_receive(:search_for).
          with(q: 'foo', rss_feeds: [news_feed, blog_feed], excluded_urls: affiliate.excluded_urls,
               since: 4.months.ago.beginning_of_day, language: 'en').
          and_return(non_video_results)

        govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
        govbox_set.news_items.should == non_video_results
        expect(govbox_set.modules).to include('NEWS')
      end

      it 'uses highlight_options' do
        expected_search_options = {
          excluded_urls: affiliate.excluded_urls,
          language: 'en',
          q: 'foo',
          rss_feeds: [news_feed, blog_feed],
          since: 4.months.ago.beginning_of_day
        }.merge(highlight_options)

        ElasticNewsItem.should_receive(:search_for).
          with(expected_search_options).
          and_return(non_video_results)

        govbox_set = GovboxSet.new('foo', affiliate, geoip_info, highlight_options)
        govbox_set.news_items.should == non_video_results
      end
    end

    context 'when an affiliate has video govbox enabled' do
      let(:youtube_feed) { mock_model(RssFeed) }
      let(:video_results) { mock('video results', total: 3) }
      before do
        affiliate.should_receive(:is_rss_govbox_enabled?).and_return(false)
        affiliate.should_receive(:is_video_govbox_enabled?).and_return(true)

        youtube_profile_ids = mock 'youtube profile ids'
        affiliate.should_receive(:youtube_profile_ids).and_return youtube_profile_ids
        RssFeed.stub_chain(:includes, :owned_by_youtube_profile, :where).and_return [youtube_feed]
      end

      it 'should retrieve video news items' do
        expected_search_options = {
          excluded_urls: affiliate.excluded_urls,
          language: 'en',
          q: 'foo',
          rss_feeds: [youtube_feed],
          since: 13.months.ago.beginning_of_day
        }.merge(highlight_options)

        ElasticNewsItem.should_receive(:search_for).with(expected_search_options).
          and_return(video_results)

        govbox_set = GovboxSet.new('foo', affiliate, geoip_info, highlight_options)
        govbox_set.video_news_items.should == video_results
        expect(govbox_set.modules).to include('VIDS')
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
            expect(govbox_set.modules).to include('MEDL')
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
            expected_tweets = mock(ElasticTweetResults, total: 1)
            ElasticTweet.should_receive(:search_for).with(q: 'foo', twitter_profile_ids: [123], since: 3.days.ago.beginning_of_day, language: "en", size: 1).and_return(expected_tweets)
            govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
            govbox_set.tweets.should == expected_tweets
            expect(govbox_set.modules).to include('TWEET')
          end

          it 'uses highlight_options' do
            expected_search_options = {
              language: "en",
              q: 'foo',
              since: 3.days.ago.beginning_of_day,
              size: 1,
              twitter_profile_ids: [123]
            }.merge(highlight_options)

            expected_tweets = mock(ElasticTweetResults, total: 1)
            ElasticTweet.should_receive(:search_for).with(expected_search_options).
              and_return(expected_tweets)
            govbox_set = GovboxSet.new('foo', affiliate, geoip_info, highlight_options)
            govbox_set.tweets.should == expected_tweets
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

    context 'when the affiliate has related search terms' do
      it 'should assign related searches' do
        SaytSuggestion.stub!(:related_search).with('foo', affiliate, {}).and_return "related search results"
        govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
        govbox_set.related_search.should == "related search results"
        expect(govbox_set.modules).to include('SREL')
      end

      it 'uses highlight options' do
        expected_search_terms = mock('search terms')
        SaytSuggestion.stub!(:related_search).with('foo', affiliate, highlight_options).
          and_return(expected_search_terms)
        govbox_set = GovboxSet.new('foo', affiliate, geoip_info, highlight_options)
        govbox_set.related_search.should == expected_search_terms
      end

    end

  end
end
