# coding: utf-8
require 'spec_helper'

describe WebSearch do
  fixtures :affiliates, :site_domains
  let(:affiliate) {  affiliates(:usagov_affiliate) }

  describe ".new" do
    before do
      @affiliate = affiliates(:usagov_affiliate)
      @valid_options = {query: 'government', affiliate: @affiliate}
    end

    it "should have a settable query" do
      search = WebSearch.new(@valid_options)
      expect(search.query).to eq('government')
    end

    it "should have a settable affiliate" do
      search = WebSearch.new(@valid_options)
      expect(search.affiliate).to eq(@affiliate)
    end

    it "should not require a query" do
      WebSearch.new({affiliate: @affiliate})
    end

    it 'should ignore invalid params' do
      search = WebSearch.new(@valid_options.merge(page: {foo: 'bar'}))
      expect(search.page).to eq(1)
    end

    it 'should ignore params outside the allowed range' do
      search = WebSearch.new(@valid_options.merge(page: -1))
      expect(search.page).to eq(Pageable::DEFAULT_PAGE)
    end

    it 'should set matching site limits' do
      @affiliate.site_domains.create!(domain: 'foo.com')
      @affiliate.site_domains.create!(domain: 'bar.gov')
      search = WebSearch.new({query: 'government', affiliate: @affiliate, site_limits: 'foo.com/subdir1 foo.com/subdir2 include3.gov'})
      expect(search.matching_site_limits).to eq(%w(foo.com/subdir1 foo.com/subdir2))
    end

    context 'when affiliate has custom google CX+Key set and google search enabled' do
      before do
        @affiliate.search_engine = "Google"
        @affiliate.google_cx = "1234567890.abc"
        @affiliate.google_key = "some_key"
      end

      it "should use that for the search" do
        expect(GoogleWebSearch).to receive(:new).with(hash_including(google_cx: "1234567890.abc", google_key: 'some_key'))
        WebSearch.new(@valid_options)
      end
    end

    skip 'when the search engine is Azure' do
      #disabling until tests are removed:
      #https://www.pivotaltracker.com/story/show/134719601

      before { @affiliate.search_engine = 'Azure' }

      it 'searches using Azure web engine' do
        HostedAzureWebEngine.should_receive(:new).
          with(hash_including(language: 'en',
                              offset: 0,
                              per_page: 10,
                              query: 'government (site:gov OR site:mil)'))

        WebSearch.new @valid_options
      end
    end

  end

  describe "#cache_key" do
    before do
      @valid_options = {query: 'government', affiliate: affiliate, page: 5}
    end

    it "should output a key based on the query, options (including affiliate id), and search engine parameters" do
      expect(WebSearch.new(@valid_options).cache_key).to eq("government (site:gov OR site:mil):{:query=>\"government\", :page=>5, :affiliate_id=>#{affiliate.id}}:BingV6")
    end
  end

  describe "instrumenting search engine calls" do
    context 'when BingV6 is the engine' do
      before do
        @valid_options = {query: 'government', affiliate: affiliate}
        bing_search = BingV6WebSearch.new(@valid_options)
        allow(BingV6WebSearch).to receive(:new).and_return bing_search
        allow(bing_search).to receive(:execute_query)
      end

      it "should instrument the call to the search engine with the proper action.service namespace and query param hash" do
        expect(affiliate.search_engine).to eq('BingV6')
        expect(ActiveSupport::Notifications).to receive(:instrument).
          with("bing_v6_web_search.usasearch", hash_including(query: hash_including(term: 'government')))
        WebSearch.new(@valid_options).send(:search)
      end
    end

    context 'when BingV7 is the engine' do
      before do
        affiliate.search_engine = 'BingV7'
        @valid_options = {query: 'government', affiliate: affiliate}
        bing_search = BingV7WebSearch.new(@valid_options)
        allow(BingV7WebSearch).to receive(:new).and_return bing_search
        allow(bing_search).to receive(:execute_query)
      end

      it "should instrument the call to the search engine with the proper action.service namespace and query param hash" do
        expect(affiliate.search_engine).to eq('BingV7')
        expect(ActiveSupport::Notifications).to receive(:instrument).
          with("bing_v7_web_search.usasearch", hash_including(query: hash_including(term: 'government')))
        WebSearch.new(@valid_options).send(:search)
      end
    end

    context 'when Google is the engine' do
      before do
        @affiliate = affiliates(:basic_affiliate)
        @valid_options = {query: 'government', affiliate: @affiliate}
        google_search = GoogleWebSearch.new(@valid_options)
        allow(GoogleWebSearch).to receive(:new).and_return google_search
        allow(google_search).to receive(:execute_query)
      end

      it "should instrument the call to the search engine with the proper action.service namespace and query param hash" do
        expect(@affiliate.search_engine).to eq('Google')
        expect(ActiveSupport::Notifications).to receive(:instrument).
          with("google_web_search.usasearch", hash_including(query: hash_including(term: 'government')))
        WebSearch.new(@valid_options).send(:search)
      end
    end
  end

  describe "#run" do
    context "when searching with a blacklisted query term" do
      before do
        @search = WebSearch.new(query: Search::BLACKLISTED_QUERIES.sample, affiliate: affiliate)
      end

      it "should return false when searching" do
        expect(@search.run).to be false
      end

      it "should have 0 results" do
        @search.run
        expect(@search.results.size).to be_zero
      end

      it "should set error message" do
        @search.run
        expect(@search.error_message).to eq(I18n.translate(:empty_query))
      end
    end

    context "when searching with really long queries" do
      before do
        @search = WebSearch.new(query: "X" * (Search::MAX_QUERYTERM_LENGTH + 1), affiliate: affiliate)
      end

      it "should return false when searching" do
        expect(@search.run).to be false
      end

      it "should have 0 results" do
        @search.run
        expect(@search.results.size).to be_zero
      end

      it "should set error message" do
        @search.run
        expect(@search.error_message).to eq(I18n.translate(:too_long))
      end
    end

    context "when paginating" do

      let(:affiliate) { affiliates(:basic_affiliate) }

      it "should default to page 1 if no valid page number was specified" do
        expect(WebSearch.new({query: 'government', affiliate: affiliate}).page).to eq(Pageable::DEFAULT_PAGE)
        expect(WebSearch.new({query: 'government', affiliate: affiliate, page: ''}).page).to eq(Pageable::DEFAULT_PAGE)
        expect(WebSearch.new({query: 'government', affiliate: affiliate, page: 'string'}).page).to eq(Pageable::DEFAULT_PAGE)
      end

      it "should set the page number" do
        search = WebSearch.new({query: 'government', affiliate: affiliate, page: 2})
        expect(search.page).to eq(2)
      end
    end

    describe "logging module impressions" do
      before do
        @search = WebSearch.new({query: 'government', affiliate: affiliates(:basic_affiliate)})
        allow(@search).to receive(:search)
        allow(@search).to receive(:handle_response)
        allow(@search).to receive(:populate_additional_results)
        allow(@search).to receive(:module_tag).and_return 'BWEB'
        allow(@search).to receive(:spelling_suggestion).and_return 'foo'
      end

      it "should assign module_tag to BWEB" do
        @search.run
        expect(@search.module_tag).to eq('BWEB')
      end

      skip 'when search_engine is Azure' do
        #disabling until tests are removed:
        #https://www.pivotaltracker.com/story/show/134719601

        subject(:search) do
          affiliate = affiliates(:usagov_affiliate)
          affiliate.site_domains.create!(domain: 'usa.gov')
          affiliate.search_engine = 'Azure'

          described_class.new(affiliate: affiliate,
                              page: 1,
                              per_page: 20,
                              query: 'healthy snack')
        end

        before { search.run }

        its(:module_tag) { is_expected.to eq('AWEB') }
        its(:fake_total?) { is_expected.to be_true }
      end

      context 'when the search_engine is Google' do
        subject(:search) do
          affiliate = affiliates(:usagov_affiliate)
          affiliate.search_engine = 'Google'

          described_class.new(affiliate: affiliate,
                              page: 1,
                              query: 'highlight enabled')
        end

        before { search.run }

        its(:module_tag) { is_expected.to eq('GWEB') }
      end

      context 'when sitelinks are present in at least one result' do
        let(:results) { [{ 'foo' => 'bar' }, { 'sitelinks' => 'yep' }] }

        before do
          @search.instance_variable_set("@results", results)
        end

        it 'should log the DECOR module' do
          @search.run
          expect(@search.modules).to include('DECOR')
        end

      end
    end

    describe "populating additional results" do
      before do
        @search = WebSearch.new(:query => 'english', :affiliate => affiliates(:non_existent_affiliate), :geoip_info => 'test')
      end

      it 'should get the info from GovboxSet' do
        expect(GovboxSet).to receive(:new).with('english', affiliates(:non_existent_affiliate), 'test', site_limits: []).and_return nil
        @search.run
      end
    end

    # TODO: remove this along with the rest of the Bing stuff being deprecated
    #       this temporary spec is only here for code coverage
    context "when the affiliate has Bing results"  do
      subject(:search) do
        affiliate = affiliates(:usagov_affiliate)
        affiliate.search_engine = 'BingV6'
        WebSearch.new(:query => 'english', :affiliate => affiliate)
      end

      it "assigns BWEB as the module_tag" do
        search.run
        expect(search.module_tag).to eq('BWEB')
      end
    end

    context "when the affiliate has no Bing/Google results, but has indexed documents" do
      before do
        ElasticIndexedDocument.recreate_index
        @non_affiliate = affiliates(:non_existent_affiliate)
        @non_affiliate.site_domains.create(:domain => "nonsense.com")
        @non_affiliate.indexed_documents.destroy_all
        1.upto(15) do |index|
          @non_affiliate.indexed_documents << IndexedDocument.new(:title => "Indexed Result no_result #{index}",
                                                                  :url => "http://nonsense.com/#{index}.html",
                                                                  :description => 'This is an indexed result no_result.',
                                                                  :last_crawl_status => IndexedDocument::OK_STATUS)
        end
        ElasticIndexedDocument.commit
        expect(@non_affiliate.indexed_documents.size).to eq(15)
        expect(ElasticIndexedDocument.search_for(q:'indexed', affiliate_id: @non_affiliate.id, language: @non_affiliate.indexing_locale).total).to eq(15)
      end

      it "should fill the results with the Odie docs" do
        search = WebSearch.new(:query => 'no_results', :affiliate => @non_affiliate)
        search.run
        expect(search.total).to eq(15)
        expect(search.startrecord).to eq(1)
        expect(search.endrecord).to eq(10)
        expect(search.results.first['unescapedUrl']).to match(/nonsense.com/)
        expect(search.results.last['unescapedUrl']).to match(/nonsense.com/)
        expect(search.module_tag).to eq('AIDOC')
      end

    end

    context "when affiliate has no Bing/Google results and IndexedDocuments search returns nil" do
      before do
        @non_affiliate = affiliates(:non_existent_affiliate)
        @non_affiliate.boosted_contents.destroy_all
        allow(ElasticIndexedDocument).to receive(:search_for).and_return nil
        @search = WebSearch.new(:query => 'no_results', :affiliate => @non_affiliate)
      end

      it "should return a search with a zero total" do
        @search.run
        expect(@search.total).to eq(0)
        expect(@search.results).not_to be_nil
        expect(@search.results).to be_empty
        expect(@search.startrecord).to be_nil
        expect(@search.endrecord).to be_nil
      end

      it "should still return true when searching" do
        expect(@search.run).to be true
      end

      it "should populate additional results" do
        expect(@search).to receive(:populate_additional_results).and_return true
        @search.run
      end

    end

    context "when affiliate has no Bing/Google results and there is an orphan document in the Odie index" do
      before do
        ElasticIndexedDocument.recreate_index
        @non_affiliate = affiliates(:non_existent_affiliate)
        @non_affiliate.indexed_documents.destroy_all
        odie = @non_affiliate.indexed_documents.create!(:title => "PDF Title", :description => "PDF Description", :url => 'http://nonsense.gov/pdf1.pdf', :doctype => 'pdf', :last_crawl_status => IndexedDocument::OK_STATUS)
        ElasticIndexedDocument.commit
        odie.delete
      end

      it "should return with zero results" do
        search = WebSearch.new(:query => 'no_results', :affiliate => @non_affiliate)
        search.run
        expect(search.results).to be_blank
      end

    end

    describe "ODIE backfill" do
      context "when we want X Bing/Google results from page Y and there are X of them" do
        before do
          @search = WebSearch.new(:query => 'english', :affiliate => affiliate)
          @search.run
        end

        it "should return the X Bing/Google results" do
          expect(@search.total).to be > 1000
          expect(@search.results.size).to eq(20)
          expect(@search.startrecord).to eq(1)
          expect(@search.endrecord).to eq(20)
        end
      end

      context "when we want X Bing/Google results from page Y and there are 0 <= n < X of them" do
        before do
          @search = WebSearch.new(query: 'odie backfill page 2', affiliate: affiliate, page: 2)
          ElasticIndexedDocument.recreate_index

          bing_api_url = "#{BingV6WebSearch::API_HOST}#{BingV6WebSearch::API_ENDPOINT}"
          page2_6results = Rails.root.join('spec/fixtures/json/bing_v6/web_search/page2_6results.json').read
          stub_request(:get, /#{bing_api_url}.*odie backfill page 2/).
            to_return( status: 200,  body: page2_6results)
        end

        context "when the affiliate has social image feeds and there are Odie results" do
          before do
            affiliate.indexed_documents.create!(
              title: 'odie backfill page 2', description: 'odie backfill page 2',
              url: 'http://nonsense.gov', last_crawl_status: IndexedDocument::OK_STATUS)
            ElasticIndexedDocument.commit
            allow(affiliate).to receive(:has_social_image_feeds?).and_return true
          end

          it "should indicate that there is another page of results" do
            @search.run
            expect(@search.total).to be >= 20
            expect(@search.results.size).to be == 6
            expect(@search.startrecord).to be == 11
            expect(@search.endrecord).to be == 16
          end
        end

        context "when there are no Odie results" do

          it "should return the X Bing/Google results" do
            @search.run
            expect(@search.total).to be >= 20
            expect(@search.results.size).to be == 6
            expect(@search.startrecord).to be == 11
            expect(@search.endrecord).to be == 16
          end
        end
      end
    end

    context 'when the affiliate has site domains and excluded domains' do
      let(:affiliate) do
        Affiliate.create!(name: 'nasa', display_name: 'Nasa', search_engine: search_engine)
      end
      let(:search) { WebSearch.new(affiliate: affiliate, query: query) }

      before do
        affiliate.site_domains.create!(domain: included_domain )
        affiliate.excluded_domains.create!(domain: excluded_domain )
        search.run
      end

      context 'when the affiliate uses Google' do
        let(:search_engine) { 'Google' }

        context 'when a subdirectory is excluded' do
          let(:excluded_domain) { 'justice.gov/archives' }
          let(:included_domain) { 'justice.gov' }
          let(:query) { 'law' }

          it 'includes the included domains' do
            search.results.each do |result|
              expect(result['unescapedUrl']).to match(%r{justice.gov})
            end
          end

          it 'excludes the excluded domains' do
            search.results.each do |result|
              expect(result['unescapedUrl']).not_to match(%r{justice.gov/archives})
            end
          end
        end

        context 'when a subdomain is excluded' do
          let(:included_domain) { 'nasa.gov' }
          let(:excluded_domain) { 'mars.nasa.gov' }
          let(:query) { 'mars' }

          it 'includes the included domains' do
            search.results.each do |result|
              expect(result['unescapedUrl']).to match(%r{nasa.gov})
            end
          end

          it 'excludes the excluded domains' do
            search.results.each do |result|
              expect(result['unescapedUrl']).not_to match(%r{mars.nasa.gov})
            end
          end
        end

        context 'when a top-level domain is included' do
          let(:included_domain) { '.gov' }
          let(:excluded_domain) { 'nasa.gov' }
          let(:query) { 'mars' }

          it 'includes the included domains' do
            search.results.each do |result|
              expect(result['unescapedUrl']).to match(%r{.gov})
            end
          end

          it 'excludes the excluded domains' do
            search.results.each do |result|
              expect(result['unescapedUrl']).not_to match(%r{nasa.gov})
            end
          end
        end
      end

      context 'when the affiliate.uses BingV6' do
        let(:search_engine) { 'BingV6' }

        context 'when a subdirectory is excluded' do
          let(:included_domain) { 'justice.gov' }
          let(:excluded_domain) { 'justice.gov/legal-careers' }
          let(:query) { 'legal careers' }

          it 'includes the included domains' do
            search.results.each do |result|
              expect(result['unescapedUrl']).to match(%r{justice.gov})
            end
          end

          # Pending: https://www.pivotaltracker.com/story/show/139210497
          xit 'excludes the excluded domains' do
            search.results.each do |result|
              expect(result['unescapedUrl']).not_to match(%r{justice.gov/legal-careers})
            end
          end
        end

        context 'when a subdomain is excluded' do
          let(:included_domain) { 'nasa.gov' }
          let(:excluded_domain) { 'mars.nasa.gov' }
          let(:query) { 'mars' }

          it 'includes the included domains' do
            search.results.each do |result|
              expect(result['unescapedUrl']).to match(%r{nasa.gov})
            end
          end

          # Pending: https://www.pivotaltracker.com/story/show/139210497
          xit 'excludes the excluded domains' do
            search.results.each do |result|
              expect(result['unescapedUrl']).not_to match(%r{mars.nasa.gov})
            end
          end
        end

        context 'when a top-level domain is included' do
          let(:included_domain) { '.gov' }
          let(:excluded_domain) { 'nasa.gov' }
          let(:query) { 'mars' }

          it 'includes the included domains' do
            search.results.each do |result|
              expect(result['unescapedUrl']).to match(%r{.gov})
            end
          end

          # Pending: https://www.pivotaltracker.com/story/show/139210497
          xit 'excludes the excluded domains' do
            search.results.each do |result|
              expect(result['unescapedUrl']).not_to match(%r{nasa.gov})
            end
          end
        end
      end
    end
  end

  describe "#as_json" do
    let(:affiliate) { affiliates(:non_existent_affiliate) }
    let(:search) { WebSearch.new(:query => 'english', :affiliate => affiliate) }

    it "should generate a JSON representation of total, start and end records, and search results" do
      search.run
      json = search.to_json
      expect(json).to match(/total/)
      expect(json).to match(/startrecord/)
      expect(json).to match(/endrecord/)
      expect(json).to match(/results/)
    end

    context "when an error occurs" do
      before do
        search.run
        search.instance_variable_set(:@error_message, "Some error")
      end

      it "should output an error if an error is detected" do
        json = search.to_json
        expect(json).to match(/"error":"Some error"/)
      end
    end

    context "when boosted contents are present" do
      before do
        affiliate.boosted_contents.create!(:title => "boosted english content", :url => "http://nonsense.gov",
                                           :description => "english description", :status => 'active', :publish_start_on => Date.current)
        ElasticBoostedContent.commit
        search.run
      end

      it "should output boosted results" do
        json = search.to_json
        expect(json).to match(%r{boosted <strong>english</strong> content})
      end
    end

    context "when jobs are present" do
      before do
        @jobs_array = []
        @jobs_array << Hashie::Mash.new(
          id: "usajobs:12345",
          position_title: "Physician  (Primary Care - Women Clinic)",
          organization_name: "Veterans Affairs, Veterans Health Administration",
          rate_interval_code: "PA",
          minimum: 60000,
          maximum: 70000,
          start_date: "2012-10-05",
          end_date: "2023-10-04",
          locations: [
            "Memphis, TN", "Lansing, MI"
          ],
          url: "https://www.usajobs.gov/GetJob/ViewDetails/12345")
        @jobs_array << Hashie::Mash.new(
          id: "usajobs:23456",
          position_title: "PHYSICAL THERAPIST",
          organization_name: "Veterans Affairs, Veterans Health Administration",
          rate_interval_code: "PA",
          minimum: 40000,
          maximum: 50000,
          start_date: "2012-10-05",
          end_date: "2023-10-04",
          locations: [
            "Fulton, MD"
          ],
          url: "https://www.usajobs.gov/GetJob/ViewDetails/23456")
        allow(search).to receive(:jobs).and_return @jobs_array
      end

      it "should output jobs" do
        json = search.to_json
        parsed = JSON.parse(json)
        expect(parsed['jobs'].to_json).to eq(@jobs_array.to_json)
      end
    end

    context "when spelling suggestion is present" do
      before do
        search.instance_variable_set(:@spelling_suggestion, "spell it this way")
      end

      it "should output spelling suggestion" do
        json = search.to_json
        expect(json).to match(/spell it this way/)
      end
    end

    context "when related search is present" do
      before do
        allow(search).to receive(:related_search).and_return ['also <strong>search</strong> this']
      end

      it "should output unhighlighted related search" do
        json = search.to_json
        expect(json).to match(/also search this/)
      end
    end
  end

  describe "#to_xml" do
    let(:affiliate) { affiliates(:non_existent_affiliate) }
    let(:search) { WebSearch.new(:query => 'english', :affiliate => affiliate) }

    it "should generate a XML representation of total, start and end records, and search results" do
      search.run
      xml = search.to_xml
      expect(xml).to match(/total/)
      expect(xml).to match(/startrecord/)
      expect(xml).to match(/endrecord/)
      expect(xml).to match(/results/)
    end

    context "when an error occurs" do
      before do
        search.run
        search.instance_variable_set(:@error_message, "Some error")
      end

      it "should output an error if an error is detected" do
        xml = search.to_xml
        expect(xml).to match(/Some error/)
      end
    end

  end

  describe "helper 'has' methods" do
    let(:search) { WebSearch.new(:query => 'english', :affiliate => affiliates(:non_existent_affiliate)) }

    it 'should raise an error when no helper can be found' do
      expect { search.not_here }.to raise_error(NoMethodError)
    end
  end

  describe 'has_fresh_news_items?' do
    let(:search) { WebSearch.new(query: 'english', affiliate: affiliate) }

    context 'when 1 or more news items are less than 6 days old' do
      let(:news_item_results) do
        [mock_model(NewsItem, published_at: DateTime.current.advance(days: 2)),
         mock_model(NewsItem, published_at: DateTime.current.advance(days: 6))]
      end
      let(:news_items) { double('news items', results: news_item_results) }

      before do
        allow(search).to receive(:news_items).and_return(news_items)
        expect(news_items).to receive(:total).and_return(2)
      end

      specify { expect(search).to have_fresh_news_items }
    end

    context 'when all news items are more than 5 days old' do
      let(:news_item_results) do
        [mock_model(NewsItem, published_at: DateTime.current.advance(days: -7)),
         mock_model(NewsItem, published_at: DateTime.current.advance(days: -12))]
      end
      let(:news_items) { double('news items', results: news_item_results) }

      before do
        allow(search).to receive(:news_items).and_return(news_items)
        expect(news_items).to receive(:total).and_return(2)
      end

      specify { expect(search).not_to have_fresh_news_items }
    end
  end
end
