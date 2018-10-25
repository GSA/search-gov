# coding: utf-8
require 'spec_helper'

describe GovboxSet do
  fixtures :affiliates, :agencies, :federal_register_agencies, :rss_feed_urls, :rss_feeds, :agency_organization_codes

  describe ".new(query, affiliate, location_name)" do
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:agency) { agencies(:irs) }
    let(:location_name) {"Washington, DC"}
    let(:highlighting_options) do
      { highlighting: true,
        pre_tags: %w(<strong>),
        post_tags: %w(</strong>) }.freeze
    end

    context 'when the affiliate has boosted contents' do
      it 'should assign boosted contents' do
        affiliate.locale = 'en'
        expected_search_options = {
          affiliate_id: affiliate.id,
          language: 'en',
          q: 'foo',
          size: 2,
          site_limits: nil
        }
        expected_results = double(ElasticBoostedContentResults, total: 1)
        allow(ElasticBoostedContent).to receive(:search_for).with(expected_search_options).
          and_return(expected_results)
        govbox_set = GovboxSet.new('foo', affiliate, location_name)
        expect(govbox_set.boosted_contents).to eq(expected_results)
        expect(govbox_set.modules).to include('BOOS')
      end

      it 'uses highlight options' do
        expected_search_options = {
          affiliate_id: affiliate.id,
          language: 'en',
          q: 'foo',
          size: 2,
          site_limits: nil
        }.merge(highlighting_options)

        expected_results = double(ElasticBoostedContentResults, total: 1)
        expect(ElasticBoostedContent).to receive(:search_for).with(expected_search_options).
          and_return(expected_results)
        govbox_set = GovboxSet.new('foo', affiliate, location_name, highlighting_options)
        expect(govbox_set.boosted_contents).to eq(expected_results)
      end
    end

    context 'when the affiliate has featured collections' do
      it 'should assign a single featured collection' do
        affiliate.locale = 'en'
        expected_results = double(ElasticFeaturedCollectionResults, total: 1)
        allow(ElasticFeaturedCollection).to receive(:search_for).
          with(q: 'foo',
               affiliate_id: affiliate.id,
               language: 'en',
               size: 1).
          and_return(expected_results)

        govbox_set = GovboxSet.new('foo', affiliate, location_name)
        expect(govbox_set.featured_collections).to eq(expected_results)
        expect(govbox_set.modules).to include('BBG')
      end

      it 'uses highlighting options' do
        expected_search_options = {
          affiliate_id: affiliate.id,
          language: 'en',
          q: 'foo',
          size: 1
        }.merge(highlighting_options)

        expected_results = double(ElasticFeaturedCollectionResults, total: 1)
        allow(ElasticFeaturedCollection).to receive(:search_for).with(expected_search_options).
          and_return(expected_results)
        govbox_set = GovboxSet.new('foo', affiliate, location_name, highlighting_options)
        expect(govbox_set.featured_collections).to eq(expected_results)
      end
    end

    context 'when the affiliate has 2 boosted contents and 1 featured collection' do
      let(:fc_expected_results) { double(ElasticFeaturedCollectionResults, total: 1) }
      let(:bc_expected_results_2) { double(ElasticBoostedContentResults, total: 1) }

      before do
        affiliate.locale = 'en'
        bc_expected_search_options = {
          affiliate_id: affiliate.id,
          language: 'en',
          q: 'foo',
          size: 2,
          site_limits: nil
        }
        bc_expected_results_1 = double(ElasticBoostedContentResults, total: 2)
        allow(ElasticBoostedContent).to receive(:search_for).with(bc_expected_search_options).
          and_return(bc_expected_results_1)
        allow(ElasticBoostedContent).to receive(:search_for).with(bc_expected_search_options.merge(size: 1)).
          and_return(bc_expected_results_2)

        allow(ElasticFeaturedCollection).to receive(:search_for).
          with(q: 'foo',
               affiliate_id: affiliate.id,
               language: 'en',
               size: 1).
          and_return(fc_expected_results)
      end

      it 'should assign 1 boosted content and 1 featured collection' do
        govbox_set = GovboxSet.new('foo', affiliate, location_name)
        expect(govbox_set.featured_collections).to eq(fc_expected_results)
        expect(govbox_set.modules).to include('BBG')
        expect(govbox_set.boosted_contents).to eq(bc_expected_results_2)
        expect(govbox_set.modules).to include('BOOS')
      end
    end

    context 'when affiliate has an agency and the federal register document govbox enabled' do
      let(:agency) { agencies(:irs) }
      let(:federal_register_agency) { federal_register_agencies(:fr_irs) }
      let(:expected_results) { double(ElasticFeaturedCollectionResults, total: 1) }

      before do
        allow(affiliate).to receive(:agency).and_return(agency)
        expect(affiliate).to receive(:is_federal_register_document_govbox_enabled?).and_return(true)
        expect(ElasticFederalRegisterDocument).to receive(:search_for).
          with(hash_including(federal_register_agency_ids: [federal_register_agency.id],
                              language: 'en',
                              q: 'foo')).
          and_return(expected_results)
      end

      it 'searches for federal register documents' do
        govbox_set = GovboxSet.new('foo', affiliate, location_name)
        expect(govbox_set.federal_register_documents).to eq(expected_results)
        expect(govbox_set.modules).to include('FRDOC')
      end

      it 'uses highlight options' do
        govbox_set = GovboxSet.new('foo', affiliate, location_name, highlighting_options)
        expect(govbox_set.federal_register_documents).to eq(expected_results)
      end
    end

    context "when the affiliate has the jobs govbox enabled" do
      let(:job_openings) do
        [Hashie::Mash.new(id: 'usajobs:359509200',
                          position_title: '<em>Nurse</em>',
                          organization_name: 'Indian Health Service',
                          rate_interval_code: 'PA',
                          minimum: 42913,
                          maximum: 61775,
                          start_date: '2014-01-16',
                          end_date: '2021-12-31',
                          locations: ['Gallup, NM', 'Dallas, TX'],
                          url: 'https://www.usajobs.gov/GetJob/ViewDetails/359509200')]
      end

      before do
        allow(affiliate).to receive(:jobs_enabled?).and_return(true)
      end

      context "when the affiliate has a related agency with an org code" do
        before do
          allow(affiliate).to receive(:agency).and_return(agency)
        end

        it "should call Jobs.search with the query, org codes, results per page, and location name params" do
          expect(Jobs).to receive(:search).
            with(query: 'foo',
                 ResultsPerPage: 10,
                 Organization: 'ABCD,BCDE',
                 LocationName: 'Washington, DC').
            and_return(job_openings)
          govbox_set = GovboxSet.new('foo', affiliate, location_name)
          expect(govbox_set.jobs.first.position_title).to eq('<strong>Nurse</strong>')
          expect(govbox_set.modules).to include('JOBS')
        end
      end

      context "when the affiliate does not have a related agency with an org code" do
        it 'should call Jobs.search with just the query, results per page' do
          expect(Jobs).to receive(:search).with(query: 'foo', ResultsPerPage: 10).and_return nil
          GovboxSet.new('foo', affiliate, nil)
        end
      end

      context 'when highlighting is enabled by default' do
        it "translates '<em>' and '</em>'" do
          expect(Jobs).to receive(:search).
            with(query: 'nursing jobs', ResultsPerPage: 10).
            and_return job_openings
          govbox_set = GovboxSet.new('nursing jobs', affiliate, nil)
          expect(govbox_set.jobs.first.position_title).to eq('<strong>Nurse</strong>')
          expect(govbox_set.jobs.first.locations).to eq(['Gallup, NM', 'Dallas, TX'])
        end

        context 'when highlighting options are assigned' do
          it "translates '<em>' and '</em>'" do
            expect(Jobs).to receive(:search).
              with(query: 'nursing jobs', ResultsPerPage: 10).
              and_return job_openings
            govbox_set = GovboxSet.new('nursing jobs',
                                       affiliate,
                                       nil,
                                       highlighting: true,
                                       pre_tags: ["\ue000"],
                                       post_tags: ["\ue001"])
            expect(govbox_set.jobs.first.position_title).to eq("\ue000Nurse\ue001")
          end
        end
      end

      context 'when highlighting is disabled' do
        let(:job_openings_no_hl) do
          [Hashie::Mash.new(id: 'usajobs:359509200',
                            position_title: 'Nurse',
                            organization_name: 'Indian Health Service',
                            rate_interval_code: 'PA',
                            minimum: 42913,
                            maximum: 61775,
                            start_date: '2014-01-16',
                            end_date: '2021-12-31',
                            locations: ['Gallup, NM'],
                            url: 'https://www.usajobs.gov/GetJob/ViewDetails/359509200')]
        end

        it 'returns position_title without highlighting' do
          expect(Jobs).to receive(:search).with(query: 'nursing jobs',
                                            size: 10,
                                            tags: 'federal').and_return(job_openings_no_hl)
          govbox_set = GovboxSet.new('nursing jobs', affiliate, nil, highlighting: false)
          expect(govbox_set.jobs.first.position_title).to eq('Nurse')
        end
      end
    end

    context "when the affiliate does not have the jobs govbox enabled" do
      before do
        allow(affiliate).to receive(:jobs_enabled?).and_return(false)
      end

      it 'should assign nil jobs' do
        govbox_set = GovboxSet.new('foo', affiliate, location_name)
        expect(govbox_set.jobs).to be_nil
      end
    end

    context 'when an affiliate has news govbox enabled' do
      let(:blog_feed) { mock_model(RssFeed, name: 'Blog', is_managed?: false) }
      let(:news_feed) { mock_model(RssFeed, name: 'News', is_managed?: false) }
      let(:non_video_results) { double('non video results', :total => 3) }

      before do
        expect(affiliate).to receive(:is_rss_govbox_enabled?).and_return(true)
        expect(affiliate).to receive(:is_video_govbox_enabled?).and_return(false)
        non_managed_feeds = [news_feed, blog_feed]
        allow(affiliate).to receive_message_chain(:rss_feeds, :non_mrss, :non_managed, :includes, :to_a).and_return non_managed_feeds
      end

      it 'should retrieve non-video news items from the last 13 months' do
        expect(ElasticNewsItem).to receive(:search_for).
          with(q: 'foo', rss_feeds: [news_feed, blog_feed], excluded_urls: affiliate.excluded_urls,
               since: 4.months.ago.beginning_of_day, language: 'en', title_only: true).
          and_return(non_video_results)

        govbox_set = GovboxSet.new('foo', affiliate, location_name)
        expect(govbox_set.news_items).to eq(non_video_results)
        expect(govbox_set.modules).to include('NEWS')
      end

      it 'uses highlight_options' do
        expected_search_options = {
          excluded_urls: affiliate.excluded_urls,
          language: 'en',
          q: 'foo',
          rss_feeds: [news_feed, blog_feed],
          since: 4.months.ago.beginning_of_day,
          title_only: true
        }.merge(highlighting_options)

        expect(ElasticNewsItem).to receive(:search_for).
          with(expected_search_options).
          and_return(non_video_results)

        govbox_set = GovboxSet.new('foo', affiliate, location_name, highlighting_options)
        expect(govbox_set.news_items).to eq(non_video_results)
      end
    end

    context 'when an affiliate has video govbox enabled' do
      let(:youtube_feed) { mock_model(RssFeed) }
      let(:video_results) { double('video results', total: 3) }
      before do
        expect(affiliate).to receive(:is_rss_govbox_enabled?).and_return(false)
        expect(affiliate).to receive(:is_video_govbox_enabled?).and_return(true)

        youtube_profile_ids = double 'youtube profile ids'
        expect(affiliate).to receive(:youtube_profile_ids).and_return youtube_profile_ids
        allow(RssFeed).to receive_message_chain(:includes, :owned_by_youtube_profile, :where).and_return [youtube_feed]
      end

      it 'should retrieve video news items' do
        expected_search_options = {
          excluded_urls: affiliate.excluded_urls,
          language: 'en',
          q: 'foo',
          rss_feeds: [youtube_feed],
          since: 13.months.ago.beginning_of_day,
          title_only: true
        }.merge(highlighting_options)

        expect(ElasticNewsItem).to receive(:search_for).with(expected_search_options).
          and_return(video_results)

        govbox_set = GovboxSet.new('foo', affiliate, location_name, highlighting_options)
        expect(govbox_set.video_news_items).to eq(video_results)
        expect(govbox_set.modules).to include('VIDS')
      end
    end

    context "med topics" do
      fixtures :med_topics
      context "when the affiliate has the medline govbox enabled" do

        before do
          allow(affiliate).to receive(:is_medline_govbox_enabled?).and_return true
        end

        context "when the search matches a MedTopic record" do
          it "should retrieve the associated Med Topic record" do
            govbox_set = GovboxSet.new('ulcerative colitis', affiliate, location_name)
            expect(govbox_set.med_topic).to eq(med_topics(:ulcerative_colitis))
            expect(govbox_set.modules).to include('MEDL')
          end

          context "when the locale is not the default" do
            before do
              I18n.locale = :es
            end

            it "should retrieve the spanish version of the med topic" do
              govbox_set = GovboxSet.new('Colitis ulcerativa', affiliate, location_name)
              expect(govbox_set.med_topic).to eq(med_topics(:ulcerative_colitis_es))
            end

            after do
              I18n.locale = I18n.default_locale
            end
          end

        end

        context "when the query does not match a med topic" do
          it "should not set the med topic" do
            govbox_set = GovboxSet.new('foo', affiliate, location_name)
            expect(govbox_set.med_topic).to be_nil
          end
        end
      end

      context "when the affiliate does not have the medline govbox enabled" do
        before do
          allow(affiliate).to receive(:is_medline_govbox_enabled?).and_return false
        end

        it "should not set the med topic" do
          govbox_set = GovboxSet.new('ulcerative colitis', affiliate, location_name)
          expect(govbox_set.med_topic).to be_nil
        end
      end
    end

    describe "twitter" do
      context "when affiliate is twitter govbox enabled" do
        before do
          allow(Twitter).to receive(:user).and_return double('Twitter')
        end

        context "when affiliate has Twitter Profiles" do
          before do
            affiliate.twitter_profiles.create!(:screen_name => 'USASearch',
                                               :name => 'Test',
                                               :twitter_id => 123,
                                               :profile_image_url => 'http://a0.twimg.com/profile_images/1879738641/USASearch_avatar_normal.png')
          end

          it "should find the most recent relevant tweet" do
            expected_tweets = double(ElasticTweetResults, total: 1)
            expect(ElasticTweet).to receive(:search_for).with(q: 'foo', twitter_profile_ids: [123], since: 3.days.ago.beginning_of_day, language: "en", size: 1).and_return(expected_tweets)
            govbox_set = GovboxSet.new('foo', affiliate, location_name)
            expect(govbox_set.tweets).to eq(expected_tweets)
            expect(govbox_set.modules).to include('TWEET')
          end

          it 'uses highlighting_options' do
            expected_search_options = {
              language: "en",
              q: 'foo',
              since: 3.days.ago.beginning_of_day,
              size: 1,
              twitter_profile_ids: [123]
            }.merge(highlighting_options)

            expected_tweets = double(ElasticTweetResults, total: 1)
            expect(ElasticTweet).to receive(:search_for).with(expected_search_options).
              and_return(expected_tweets)
            govbox_set = GovboxSet.new('foo', affiliate, location_name, highlighting_options)
            expect(govbox_set.tweets).to eq(expected_tweets)
          end
        end

        context "when affiliate has no Twitter Profiles" do
          it "should not set tweets" do
            govbox_set = GovboxSet.new('foo', affiliate, location_name)
            expect(govbox_set.tweets).to be_nil
          end
        end
      end
    end

    context 'when the affiliate has related search terms' do
      let(:expected_search_terms) { double('search terms') }

      it 'should assign related searches' do
        allow(SaytSuggestion).to receive(:related_search).with('foo', affiliate, {}).
          and_return(expected_search_terms)
        govbox_set = GovboxSet.new('foo', affiliate, location_name)
        expect(govbox_set.related_search).to eq(expected_search_terms)
        expect(govbox_set.modules).to include('SREL')
      end

      it 'uses highlighting options' do
        allow(SaytSuggestion).to receive(:related_search).with('foo', affiliate, highlighting_options).
          and_return(expected_search_terms)
        govbox_set = GovboxSet.new('foo', affiliate, location_name, highlighting_options)
        expect(govbox_set.related_search).to eq(expected_search_terms)
      end

    end

    context 'when site_limits option is present' do
      before do
        expect(ElasticFeaturedCollection).not_to receive(:search_for)
        expect(affiliate).not_to receive(:is_federal_register_document_govbox_enabled?)
        expect(affiliate).not_to receive(:is_medline_govbox_enabled?)
        expect(affiliate).not_to receive(:is_rss_govbox_enabled?)
        expect(affiliate).not_to receive(:is_video_govbox_enabled?)
        expect(affiliate).not_to receive(:jobs_enabled?)
        expect(affiliate).not_to receive(:searchable_twitter_ids)
        expect(SaytSuggestion).not_to receive(:related_search)
      end

      it 'searches only on text best bets' do
        affiliate.locale = 'en'
        expected_results = double(ElasticBoostedContentResults, total: 1)
        allow(ElasticBoostedContent).to receive(:search_for).
          with(q: 'foo',
               affiliate_id: affiliate.id,
               language: 'en',
               size: 2,
               site_limits: %w(blogs.usa.gov news.usa.gov)).
          and_return(expected_results)

        govbox_set = GovboxSet.new('foo',
                                   affiliate, location_name,
                                   site_limits: %w(https://blogs.usa.gov http://news.usa.gov))
        expect(govbox_set.boosted_contents).to eq(expected_results)
        expect(govbox_set.modules).to include('BOOS')
      end
    end
  end
end
