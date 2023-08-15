# frozen_string_literal: true

describe GovboxSet do
  describe '.new(query, affiliate, geoip_info)' do
    subject(:govbox_set) do
      described_class.new('foo', affiliate, geoip_info, highlighting_options)
    end

    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:agency) { agencies(:irs) }
    let(:geoip_info) do
      instance_double(
        GeoIP::City, location_name: 'Flemington, New Jersey, United States'
      )
    end

    let(:highlighting_options) do
      { highlighting: true,
        pre_tags: %w[<strong>],
        post_tags: %w[</strong>] }.freeze
    end

    describe '#as_json' do
      subject(:govbox_set_json) { govbox_set.as_json }

      context 'when there are text best bets' do
        let(:text_best_bet) { BoostedContent.new(title: 'Support', url: 'https://search.gov/support.html', description: '<strong>GSA</strong> support') }
        let(:elastic_boosted_content_results) { instance_double(ElasticBoostedContentResults, total: 1, results: [text_best_bet]) }

        before do
          allow(ElasticBoostedContent).to receive(:search_for).and_return(elastic_boosted_content_results)
        end

        it 'returns the affiliate display name and an array of text best bets' do
          expect(govbox_set_json).to eq({
                                          recommendedBy: affiliate.display_name,
                                          textBestBets: [{ 'description' => text_best_bet.description, 'title' => text_best_bet.title, 'url' => text_best_bet.url }]
                                        })
        end
      end

      context 'when there is a graphic best bet' do
        let(:graphic_best_bet) { FeaturedCollection.new(title: 'Search USA Blog', status: 'active', publish_start_on: '07/01/2011', affiliate: affiliate) }
        let(:elastic_featured_collection_results) { instance_double(ElasticFeaturedCollectionResults, total: 1, results: [graphic_best_bet]) }

        before do
          graphic_best_bet.featured_collection_links.build(title: 'Blog Post', url: 'https://search.gov/blog-1', position: 0)
          graphic_best_bet.save!
          allow(ElasticFeaturedCollection).to receive(:search_for).and_return(elastic_featured_collection_results)
        end

        it 'returns the affiliate display name and a hash for the graphics best bet' do
          expect(govbox_set_json).to eq({
                                          recommendedBy: affiliate.display_name,
                                          graphicsBestBet: { links: [{ title: 'Blog Post', url: 'https://search.gov/blog-1' }], title: 'Search USA Blog', title_url: nil }
                                        })
        end
      end

      context 'when there is a health topic' do
        fixtures :med_topics

        subject(:govbox_set_json) do
          described_class.new('cancer', affiliate, geoip_info, highlighting_options).as_json
        end

        before do
          allow(affiliate).to receive(:is_medline_govbox_enabled?).and_return true
          topic = MedTopic.find_by(medline_title: 'cancer')
          topic.med_sites.clear
          topic.med_sites << MedSite.find_or_create_by(title: 'Carcinoma', url: 'https://clinicaltrials.gov/search/open/condition=%22Carcinoma%22', med_topic_id: topic.id)
          topic.save
        end

        it 'returns the affiliate display name and a hash for the health topic' do
          expect(govbox_set_json).to eq({
                                          healthTopic: {
                                            title: 'Cancer',
                                            description: 'Cancer begins in your cells, which are the building blocks of your body. Normally, your body forms new cells as you need them, replacing old cells that die. Sometimes this process goes wrong.',
                                            url: 'https://www.nlm.nih.gov/medlineplus/cancer.html',
                                            studiesAndTrials: [
                                              { 'title' => 'Carcinoma', 'url' => 'https://clinicaltrials.gov/search/open/condition=%22Carcinoma%22' }
                                            ],
                                            relatedTopics: [
                                              { 'title' => 'Cancer Alternative Therapies', 'url' => 'https://www.nlm.nih.gov/medlineplus/canceralternativetherapies.html' },
                                              { 'title' => 'Cancer and Pregnancy', 'url' => 'https://www.nlm.nih.gov/medlineplus/cancerandpregnancy.html' }
                                            ]
                                          },
                                          recommendedBy: 'NPS Site'
                                        })
        end
      end

      context 'when there are job results' do
        subject(:govbox_set_json) do
          described_class.new('jobs', affiliate, geoip_info, highlighting_options).as_json
        end

        let(:job_attributes) { %w[application_close_date maximum_pay minimum_pay organization_name position_location_display position_title position_uri rate_interval_code] }

        before do
          allow(affiliate).to receive(:jobs_enabled?).and_return(true)
        end

        it 'returns ten jobs' do
          expect(govbox_set_json[:jobs].length).to eq(10)
        end

        it 'has valid keys for all jobs' do
          govbox_set_json[:jobs].each do |job|
            expect(job.keys).to match_array(job_attributes)
          end
        end

        it 'returns valid data for the first job' do
          expect(govbox_set_json[:jobs].first).to eq({
                                                       'application_close_date' => 'January 25, 2024',
                                                       'maximum_pay' => 170_800.0,
                                                       'minimum_pay' => 64_660.0,
                                                       'organization_name' => 'Office of the Secretary of Health and Human Services',
                                                       'position_location_display' => 'Multiple Locations',
                                                       'position_title' => 'General Attorney Advisor',
                                                       'position_uri' => 'https://www.usajobs.gov:443/GetJob/ViewDetails/523056100',
                                                       'rate_interval_code' => 'PA'
                                                     })
        end
      end

      context 'when there are federal register documents' do
        let(:agency) { agencies(:irs) }
        let(:federal_register_agency) { federal_register_agencies(:fr_irs) }
        let(:federal_register_document) do
          FederalRegisterDocument.new(
            document_number: 1,
            title: 'Test FRD',
            abstract: 'This is a test FRD.',
            html_url: 'http://www.federalregister.gov/articles/2016/05/11/2016-10932/unsuccessful-work',
            document_type: 'Proposed Rule',
            start_page: 2,
            end_page: 5,
            page_length: 4,
            publication_date: Date.new(2020, 1, 2, 3),
            comments_close_on: Date.new(2024, 4, 5, 6)
          )
        end
        let(:federal_agency_names) { ['GSA'] }
        let(:results) { instance_double(ElasticFederalRegisterDocumentResults, total: 1, results: [federal_register_document]) }

        before do
          allow(affiliate).to receive(:agency).and_return(agency)
          allow(affiliate).to receive(:is_federal_register_document_govbox_enabled?).and_return(true)
          allow(federal_register_document).to receive(:contributing_agency_names).and_return(federal_agency_names)
          allow(ElasticFederalRegisterDocument).to receive(:search_for).
            and_return(results)
        end

        it 'returns the affiliate display name and an array of federal register documents' do
          expect(govbox_set_json).to eq({
                                          recommendedBy: affiliate.display_name,
                                          federalRegisterDocuments: [
                                            { 'comments_close_on' => federal_register_document.comments_close_on.to_fs(:long),
                                              'document_number' => federal_register_document.document_number,
                                              'document_type' => federal_register_document.document_type,
                                              'end_page' => federal_register_document.end_page,
                                              'page_length' => federal_register_document.page_length,
                                              'publication_date' => federal_register_document.publication_date.to_fs(:long),
                                              'start_page' => federal_register_document.start_page,
                                              'contributing_agency_names' => federal_agency_names,
                                              'html_url' => federal_register_document.html_url,
                                              'title' => federal_register_document.title }
                                          ]
                                        })
        end
      end

      context 'when there are video results' do
        before do
          allow(affiliate).to receive(:is_video_govbox_enabled?).and_return(true)

          youtube_profile = youtube_profiles(:whitehouse)
          rss_feed_url = youtube_profile.rss_feed.rss_feed_urls.first
          rss_feed_url.news_items.delete_all

          news_items = (1..2).map do |i|
            NewsItem.new(rss_feed_url: rss_feed_url,
                             link: "http://www.youtube.com/watch?v=#{i}&feature=youtube_gdata",
                             title: "video #{i}",
                             description: "video news description #{i}",
                             published_at: Date.new(2011, 9, 26),
                             guid: "http://gdata.youtube.com/feeds/base/videos/#{i}",
                             duration: "#{i}:0#{i}",
                             updated_at: Time.current)
          end

          elastic_results = double(ElasticNewsItemResults,
                                   results: news_items,
                                   total: 30)

          allow(ElasticNewsItem).to receive(:search_for).and_return(elastic_results)
          allow(affiliate).to receive(:is_video_govbox_enabled?).and_return(true)
        end

        after do
          NewsItem.destroy_all
        end

        it 'returns the affiliate display name and an array of video news items' do
          expect(govbox_set_json).to eq({
                                          recommendedBy: affiliate.display_name,
                                          youtubeNewsItems: [
                                            {
                                              'description' => 'video news description 1',
                                              'link' => 'http://www.youtube.com/watch?v=1&feature=youtube_gdata',
                                              'published_at' => 'September 26, 2011 00:00',
                                              'title' => 'video 1',
                                              'youtube_thumbnail_url' => 'https://i.ytimg.com/vi/1/default.jpg'
                                            },
                                            {
                                              'description' => 'video news description 2',
                                              'link' => 'http://www.youtube.com/watch?v=2&feature=youtube_gdata',
                                              'published_at' => 'September 26, 2011 00:00',
                                              'title' => 'video 2',
                                              'youtube_thumbnail_url' => 'https://i.ytimg.com/vi/2/default.jpg'
                                            }
                                          ]})
        end
      end

      context 'when there are new news results' do
        let(:news_item) { NewsItem.new(title: 'title', link: 'https://www.search.gov', description: 'description', published_at: Date.current - 2) }
        let(:news_results) { instance_double(ElasticNewsItemResults, total: 1, results: [news_item]) }

        before do
          allow(affiliate).to receive(:is_video_govbox_enabled?).and_return(false)
          allow(affiliate).to receive(:is_rss_govbox_enabled?).and_return(true)
          allow(ElasticNewsItem).to receive(:search_for).and_return(news_results)
        end

        it 'returns the news results' do
          expect(govbox_set_json).to eq({
                                          recommendedBy: affiliate.display_name,
                                          newNews: [{
                                            description: news_item.description,
                                            link: news_item.link,
                                            publishedAt: news_item.published_at.to_date,
                                            title: news_item.title
                                          }]
                                        })
        end
      end

      context 'when there are old news results' do
        let(:news_item) { NewsItem.new(title: 'title', link: 'https://www.search.gov', description: 'description', published_at: Date.current - 10) }
        let(:news_results) { instance_double(ElasticNewsItemResults, total: 1, results: [news_item]) }

        before do
          allow(affiliate).to receive(:is_video_govbox_enabled?).and_return(false)
          allow(affiliate).to receive(:is_rss_govbox_enabled?).and_return(true)
          allow(ElasticNewsItem).to receive(:search_for).and_return(news_results)
        end

        it 'returns the news results' do
          expect(govbox_set_json).to eq({
                                          recommendedBy: affiliate.display_name,
                                          oldNews: [{
                                            description: news_item.description,
                                            link: news_item.link,
                                            publishedAt: news_item.published_at.to_date,
                                            title: news_item.title
                                          }]
                                        })
        end
      end

      context 'when there is no additional result data' do
        it 'returns the affiliate display name' do
          expect(govbox_set_json).to eq({
                                          recommendedBy: affiliate.display_name
                                        })
        end
      end
    end

    describe '#boosted_contents' do
      context 'when the affiliate has boosted contents' do
        it 'assigns boosted contents' do
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
          govbox_set = described_class.new('foo', affiliate, geoip_info)
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
          govbox_set = described_class.new('foo', affiliate, geoip_info, highlighting_options)
          expect(govbox_set.boosted_contents).to eq(expected_results)
        end
      end

      context 'when the affiliate does not have boosted contents' do
        before do
          allow(affiliate).to receive(:boosted_contents).and_return([])
        end

        it 'does not query Elasticsearch for boosted contents' do
          expect(ElasticBoostedContent).not_to receive(:search_for)
          govbox_set.boosted_contents
        end
      end
    end

    describe '#graphic_best_bets' do
      context 'when the affiliate has featured collections' do
        it 'assigns a single featured collection' do
          affiliate.locale = 'en'
          expected_results = double(ElasticFeaturedCollectionResults, total: 1)
          allow(ElasticFeaturedCollection).to receive(:search_for).
            with({ q: 'foo',
                   affiliate_id: affiliate.id,
                   language: 'en',
                   size: 1 }).
            and_return(expected_results)

          govbox_set = described_class.new('foo', affiliate, geoip_info)
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
          govbox_set = described_class.new('foo', affiliate, geoip_info, highlighting_options)
          expect(govbox_set.featured_collections).to eq(expected_results)
        end
      end

      context 'when the affiliate does not have featured collections' do
        before do
          allow(affiliate).to receive(:featured_collections).and_return([])
        end

        it 'does not query Elasticsearch for featured collections' do
          expect(ElasticFeaturedCollection).not_to receive(:search_for)
          govbox_set.featured_collections
        end
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
          with({ q: 'foo',
                 affiliate_id: affiliate.id,
                 language: 'en',
                 size: 1 }).
          and_return(fc_expected_results)
      end

      it 'should assign 1 boosted content and 1 featured collection' do
        govbox_set = described_class.new('foo', affiliate, geoip_info)
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
        govbox_set = described_class.new('foo', affiliate, geoip_info)
        expect(govbox_set.federal_register_documents).to eq(expected_results)
        expect(govbox_set.modules).to include('FRDOC')
      end

      it 'uses highlight options' do
        govbox_set = described_class.new('foo', affiliate, geoip_info, highlighting_options)
        expect(govbox_set.federal_register_documents).to eq(expected_results)
      end
    end

    context 'when the affiliate has the jobs govbox enabled' do
      let(:govbox_set) { described_class.new('job', affiliate, geoip_info) }

      before do
        allow(affiliate).to receive(:jobs_enabled?).and_return(true)
      end

      it "includes 'JOBS' in the modules" do
        expect(govbox_set.modules).to include('JOBS')
      end

      it 'returns job results' do
        expect(govbox_set.jobs.count).to be > 0
      end

      context 'when the affiliate has a related agency with an org code' do
        before do
          allow(affiliate).to receive(:agency).and_return(agency)
        end

        it 'should call Jobs.search with the params' do
          expect(Jobs).to receive(:search).
            with({ query: 'job',
                   organization_codes: 'ABCD;BCDE',
                   results_per_page: 10,
                   location_name: 'Flemington, New Jersey, United States' })
          govbox_set = described_class.new('job', affiliate, geoip_info)
        end
      end

      context 'when the affiliate does not have a related agency with an org code' do
        it 'calls Jobs.search with just the query, results per page' do
          expect(Jobs).to receive(:search).with({ query: 'job',
                                                  organization_codes: nil,
                                                  results_per_page: 10,
                                                  location_name: nil }).and_return nil
          described_class.new('job', affiliate, nil)
        end
      end
    end

    context 'when the affiliate does not have the jobs govbox enabled' do
      before do
        allow(affiliate).to receive(:jobs_enabled?).and_return(false)
      end

      it 'should assign nil jobs' do
        govbox_set = described_class.new('foo', affiliate, geoip_info)
        expect(govbox_set.jobs).to be_nil
      end
    end

    context 'when an affiliate has news govbox enabled' do
      let(:blog_feed) { mock_model(RssFeed, name: 'Blog', is_managed?: false) }
      let(:news_feed) { mock_model(RssFeed, name: 'News', is_managed?: false) }
      let(:non_video_results) { double('non video results', total: 3) }

      before do
        expect(affiliate).to receive(:is_rss_govbox_enabled?).and_return(true)
        expect(affiliate).to receive(:is_video_govbox_enabled?).and_return(false)
        non_managed_feeds = [news_feed, blog_feed]
        allow(affiliate).to receive_message_chain(:rss_feeds, :non_mrss, :non_managed, :includes, :to_a).
          and_return(non_managed_feeds)
      end

      it 'should retrieve non-video news items from the last 13 months' do
        expect(ElasticNewsItem).to receive(:search_for).
          with({ q: 'foo', rss_feeds: [news_feed, blog_feed], excluded_urls: affiliate.excluded_urls,
                 since: 4.months.ago.beginning_of_day, language: 'en', title_only: true }).
          and_return(non_video_results)

        govbox_set = described_class.new('foo', affiliate, geoip_info)
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

        govbox_set = described_class.new('foo', affiliate, geoip_info, highlighting_options)
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

        govbox_set = described_class.new('foo', affiliate, geoip_info, highlighting_options)
        expect(govbox_set.video_news_items).to eq(video_results)
        expect(govbox_set.modules).to include('VIDS')
      end
    end

    context 'med topics' do
      fixtures :med_topics
      context 'when the affiliate has the medline govbox enabled' do
        before do
          allow(affiliate).to receive(:is_medline_govbox_enabled?).and_return true
        end

        context 'when the search matches a MedTopic record' do
          it 'should retrieve the associated Med Topic record' do
            govbox_set = described_class.new('ulcerative colitis', affiliate, geoip_info)
            expect(govbox_set.med_topic).to eq(med_topics(:ulcerative_colitis))
            expect(govbox_set.modules).to include('MEDL')
          end

          context 'when the locale is not the default' do
            before do
              I18n.locale = :es
            end

            after do
              I18n.locale = I18n.default_locale
            end

            it 'should retrieve the spanish version of the med topic' do
              govbox_set = described_class.new('Colitis ulcerativa', affiliate, geoip_info)
              expect(govbox_set.med_topic).to eq(med_topics(:ulcerative_colitis_es))
            end
          end
        end

        context 'when the query does not match a med topic' do
          it 'should not set the med topic' do
            govbox_set = described_class.new('foo', affiliate, geoip_info)
            expect(govbox_set.med_topic).to be_nil
          end
        end
      end

      context 'when the affiliate does not have the medline govbox enabled' do
        before do
          allow(affiliate).to receive(:is_medline_govbox_enabled?).and_return false
        end

        it 'should not set the med topic' do
          govbox_set = described_class.new('ulcerative colitis', affiliate, geoip_info)
          expect(govbox_set.med_topic).to be_nil
        end
      end
    end

    describe '#related_search' do
      context 'when the affiliate has related search terms' do
        let(:expected_search_terms) { double('search terms') }

        it 'should assign related searches' do
          allow(SaytSuggestion).to receive(:related_search).with('foo', affiliate, {}).
            and_return(expected_search_terms)
          govbox_set = described_class.new('foo', affiliate, geoip_info)
          expect(govbox_set.related_search).to eq(expected_search_terms)
          expect(govbox_set.modules).to include('SREL')
        end

        it 'uses highlighting options' do
          allow(SaytSuggestion).to receive(:related_search).with('foo', affiliate, highlighting_options).
            and_return(expected_search_terms)
          govbox_set = described_class.new('foo', affiliate, geoip_info, highlighting_options)
          expect(govbox_set.related_search).to eq(expected_search_terms)
        end
      end

      context 'when the affiliate does not have related searches enabled' do
        before do
          allow(affiliate).to receive(:is_related_searches_enabled?).
            and_return(false)
        end

        it 'does not query Elasticsearch for related searches' do
          expect(SaytSuggestion).not_to receive(:related_search)
          govbox_set.related_search
        end
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
        expect(SaytSuggestion).not_to receive(:related_search)
      end

      it 'searches only on text best bets' do
        affiliate.locale = 'en'
        expected_results = double(ElasticBoostedContentResults, total: 1)
        allow(ElasticBoostedContent).to receive(:search_for).
          with({ q: 'foo',
                 affiliate_id: affiliate.id,
                 language: 'en',
                 size: 2,
                 site_limits: %w[blogs.usa.gov news.usa.gov] }).
          and_return(expected_results)

        govbox_set = described_class.new('foo',
                                         affiliate, geoip_info,
                                         site_limits: %w[https://blogs.usa.gov http://news.usa.gov])
        expect(govbox_set.boosted_contents).to eq(expected_results)
        expect(govbox_set.modules).to include('BOOS')
      end
    end
  end
end
