# coding: utf-8
require 'spec_helper'

describe WebSearch do
  fixtures :affiliates

  describe ".new" do
    before do
      @affiliate = affiliates(:usagov_affiliate)
      @valid_options = {query: 'government', affiliate: @affiliate}
    end

    it "should have a settable query" do
      search = WebSearch.new(@valid_options)
      search.query.should == 'government'
    end

    it "should have a settable affiliate" do
      search = WebSearch.new(@valid_options.merge(:affiliate => @affiliate))
      search.affiliate.should == @affiliate
    end

    it "should not require a query or affiliate" do
      WebSearch.new
    end

    it 'should ignore invalid params' do
      search = WebSearch.new(@valid_options.merge(page: {foo: 'bar'}, per_page: {bar: 'foo'}))
      search.page.should == 1
      search.per_page.should == 10
    end

    it 'should ignore params outside the allowed range' do
      search = WebSearch.new(@valid_options.merge(page: -1, per_page: 100))
      search.page.should == Search::DEFAULT_PAGE
      search.per_page.should == Search::DEFAULT_PER_PAGE
    end

    context "when a results per page number is specified" do
      it "should construct a query string with the appropriate per page variable set" do
        search = WebSearch.new(@valid_options.merge(:per_page => 20))
        search.per_page.should == 20
      end

      it "should not set a per page value above 50" do
        search = WebSearch.new(@valid_options.merge(:per_page => 51))
        search.per_page.should == 10
      end

      context "when the per_page variable passed is blank" do
        it "should set the per-page parameter to the default value, defined by the DEFAULT_PER_PAGE variable" do
          search = WebSearch.new(@valid_options)
          search.per_page.should == 10
        end
      end
    end
  end

  describe "instrumenting search engine calls" do
    context 'when Bing is the engine' do
      before do
        @affiliate = affiliates(:usagov_affiliate)
        @valid_options = {query: 'government', affiliate: @affiliate}
        bing_search = BingSearch.new(@valid_options)
        BingSearch.stub!(:new).and_return bing_search
        bing_search.stub!(:execute_query).and_return
      end

      it "should instrument the call to the search engine with the proper action.service namespace and query param hash" do
        @affiliate.search_engine.should == 'Bing'
        ActiveSupport::Notifications.should_receive(:instrument).
          with("bing_search.usasearch", hash_including(query: hash_including(term: 'government')))
        WebSearch.new(@valid_options).send(:search)
      end
    end

    context 'when Google is the engine' do
      before do
        @affiliate = affiliates(:basic_affiliate)
        @valid_options = {query: 'government', affiliate: @affiliate}
        google_search = GoogleSearch.new(@valid_options)
        GoogleSearch.stub!(:new).and_return google_search
        google_search.stub!(:execute_query).and_return
      end

      it "should instrument the call to the search engine with the proper action.service namespace and query param hash" do
        @affiliate.search_engine.should == 'Google'
        ActiveSupport::Notifications.should_receive(:instrument).
          with("google_search.usasearch", hash_including(query: hash_including(term: 'government')))
        WebSearch.new(@valid_options).send(:search)
      end
    end
  end

  describe "#run" do
    #context "when the search engine returns zero results" do
    #  before do
    #    @search = WebSearch.new(@valid_options.merge(:query => 'abydkldkd'))
    #  end
    #
    #  it "should still return true when searching" do
    #    @search.run.should be_true
    #  end
    #
    #  it "should populate additional results" do
    #    @search.should_receive(:populate_additional_results).and_return true
    #    @search.run
    #  end
    #
    #  it "should have 0 results" do
    #    @search.run
    #    @search.results.size.should == 0
    #  end
    #
    #end

    context "when searching with really long queries" do
      before do
        @search = WebSearch.new(query: "X" * (Search::MAX_QUERYTERM_LENGTH + 1), affiliate: affiliates(:usagov_affiliate))
      end

      it "should return false when searching" do
        @search.run.should be_false
      end

      it "should have 0 results" do
        @search.run
        @search.results.size.should be_zero
      end

      it "should set error message" do
        @search.run
        @search.error_message.should == 'That is too long a word. Try using a shorter word.'
      end
    end

    context "when paginating" do
      #default_page = 1

      it "should default to page 1 if no valid page number was specified" do
        options_without_page = @valid_options.reject { |k, v| k == :page }
        WebSearch.new(options_without_page).page.should == Search::DEFAULT_PAGE
        WebSearch.new(@valid_options.merge(:page => '')).page.should == Search::DEFAULT_PAGE
        WebSearch.new(@valid_options.merge(:page => 'string')).page.should == Search::DEFAULT_PAGE
      end

      it "should set the page number" do
        search = WebSearch.new(@valid_options.merge(:page => 2))
        search.page.should == 2
      end

      it "should use the underlying engine's results per page" do
        search = WebSearch.new(@valid_options)
        search.run
        search.results.size.should == WebSearch::DEFAULT_PER_PAGE
      end

      it "should set startrecord/endrecord" do
        page = 7
        search = WebSearch.new(@valid_options.merge(:page => page))
        search.run
        search.startrecord.should == WebSearch::DEFAULT_PER_PAGE * (page-1) + 1
        search.endrecord.should == search.startrecord + search.results.size - 1
      end

      context "when the page is greater than the number of results" do
        before do
          json = File.read(Rails.root.to_s + "/spec/fixtures/json/bing_results_for_a_large_result_set.json")
          parsed = JSON.parse(json)
          JSON.stub!(:parse).and_return parsed
          @affiliate.indexed_documents.delete_all
          IndexedDocument.reindex
          Sunspot.commit
        end

        it "should use Bing's total but leave start/endrecord nil" do
          search = WebSearch.new(:query => 'government', :affiliate => @affiliate, :page => 97)
          search.run.should be_true
          search.total.should == 622
          search.startrecord.should be_nil
          search.endrecord.should be_nil
        end
      end
    end

    context "on normal search runs" do
      before do
        @search = WebSearch.new(@valid_options.merge(:page => 1, :query => 'logme', :affiliate => @affiliate))
        @search.stub!(:backfill_needed).and_return false
        parsed = JSON.parse(File.read(::Rails.root.to_s + "/spec/fixtures/json/spelling/spelling_suggestions.json"))
        JSON.stub!(:parse).and_return parsed
      end

      it "should assign module_tag to BWEB" do
        @search.run
        @search.module_tag.should == 'BWEB'
      end

      it "should log info about the query" do
        QueryImpression.should_receive(:log).with(:web, @affiliate.name, 'logme', %w{BWEB OVER BSPEL})
        @search.run
      end
    end

    context "when there are jobs results" do
      before do
        @search = WebSearch.new(@valid_options.merge(:page => 1, :query => 'logme jobs', :affiliate => @affiliate))
        @affiliate.stub!(:jobs_enabled?).and_return true
        @search.stub!(:backfill_needed).and_return false
        parsed = JSON.parse(File.read(::Rails.root.to_s + "/spec/fixtures/json/spelling/spelling_suggestions.json"))
        JSON.stub!(:parse).and_return parsed
        Usajobs.stub!(:search).and_return %w{some array}
      end

      it "should log info about the query" do
        QueryImpression.should_receive(:log).with(:web, @affiliate.name, 'logme jobs', %w{BWEB OVER BSPEL JOBS})
        @search.run
      end
    end

    context "when the affiliate has no Bing results, but has indexed documents" do
      before do
        @non_affiliate = affiliates(:non_existant_affiliate)
        @non_affiliate.site_domains.create(:domain => "nonsense.com")
        @non_affiliate.indexed_documents.destroy_all
        1.upto(15) do |index|
          @non_affiliate.indexed_documents << IndexedDocument.new(:title => "Indexed Result #{index}", :url => "http://nonsense.com/#{index}.html", :description => 'This is an indexed result.', :last_crawl_status => IndexedDocument::OK_STATUS)
        end
        IndexedDocument.reindex
        Sunspot.commit
        @non_affiliate.indexed_documents.size.should == 15
        IndexedDocument.search_for('indexed', @non_affiliate, nil).total.should == 15
      end

      it "should fill the results with the Odie docs" do
        search = WebSearch.new(:query => 'indexed', :affiliate => @non_affiliate)
        search.run
        search.results.should_not be_nil
        search.results.should_not be_empty
        search.total.should == 15
        search.startrecord.should == 1
        search.endrecord.should == 10
        search.results.first['unescapedUrl'].should == "http://nonsense.com/1.html"
        search.results.last['unescapedUrl'].should == "http://nonsense.com/10.html"
        search.indexed_documents.should be_nil
        #TODO: change this
        search.are_results_by_bing?.should be_false
      end

      it 'should log info about the query' do
        QueryImpression.should_receive(:log).with(:web, @non_affiliate.name, 'indexed', %w{AIDOC})
        search = WebSearch.new(:query => 'indexed', :affiliate => @non_affiliate)
        search.run
      end
    end

    context "when affiliate has no Bing results and IndexedDocuments search returns nil" do
      before do
        @non_affiliate = affiliates(:non_existant_affiliate)
        @non_affiliate.boosted_contents.destroy_all
        IndexedDocument.stub!(:search_for).and_return nil
      end

      it "should return a search with a zero total" do
        search = WebSearch.new(:query => 'some bogus + + query', :affiliate => @non_affiliate)
        search.run
        search.total.should == 0
        search.results.should_not be_nil
        search.results.should be_empty
        search.startrecord.should be_nil
        search.endrecord.should be_nil
      end

      it 'should log info about the query' do
        QueryImpression.should_receive(:log).with(:web, @non_affiliate.name, 'some bogus + + query', [])
        search = WebSearch.new(:query => 'some bogus + + query', :affiliate => @non_affiliate)
        search.run
      end
    end

    context "when affiliate has no Bing results and there is an orphan indexed document" do
      before do
        @non_affiliate = affiliates(:non_existant_affiliate)
        @non_affiliate.indexed_documents.destroy_all
        IndexedDocument.reindex
        odie = @non_affiliate.indexed_documents.create!(:title => "PDF Title", :description => "PDF Description", :url => 'http://laksjdflkjasldkjfalskdjf.gov/pdf1.pdf', :doctype => 'pdf', :last_crawl_status => IndexedDocument::OK_STATUS)
        Sunspot.commit
        odie.delete
        IndexedDocument.solr_search_ids { with :affiliate_id, affiliates(:non_existant_affiliate).id }.first.should == odie.id
      end

      it "should return with zero results" do
        search = WebSearch.new(:query => 'PDF', :affiliate => @non_affiliate)
        search.should_not_receive(:highlight_solr_hit_like_bing)
        search.run
        search.results.should be_blank
      end

      after do
        IndexedDocument.reindex
      end
    end

    describe "ODIE backfill" do
      context "when we want X Bing results from page Y and there are X of them" do
        before do
          @search = WebSearch.new(@valid_options.merge(:page => 1))
          json = File.read(Rails.root.to_s + "/spec/fixtures/json/page1_10results.json")
          parsed = JSON.parse(json)
          JSON.stub!(:parse).and_return parsed
          @search.run
        end

        it "should return the X Bing results" do
          @search.total.should == 1940000
          @search.results.size.should == 10
          @search.startrecord.should == 1
          @search.endrecord.should == 10
        end
      end

      context "when we want X Bing results from page Y and there are 0 <= n < X of them" do
        before do
          @search = WebSearch.new(@valid_options.merge(:page => 2))
          json = File.read(Rails.root.to_s + "/spec/fixtures/json/page2_6results.json")
          parsed = JSON.parse(json)
          JSON.stub!(:parse).and_return parsed
        end

        context "when there are Odie results" do
          before do
            IndexedDocument.destroy_all
            @affiliate.site_domains.create!(:domain => 'nps.gov')
            @affiliate.indexed_documents.create!(:title => 'government I LOVE AMERICA', :description => 'government WE LOVE AMERICA', :url => 'http://nps.gov/america.html', :last_crawl_status => IndexedDocument::OK_STATUS)
            IndexedDocument.reindex
            Sunspot.commit
          end

          it "should indicate that there is another page of results" do
            @search.run
            @search.total.should == 21
            @search.results.size.should == 6
            @search.startrecord.should == 11
            @search.endrecord.should == 16
          end

        end

        context "when there are no Odie results" do
          before do
            IndexedDocument.destroy_all
            IndexedDocument.reindex
            Sunspot.commit
          end

          it "should return the X Bing results" do
            @search.run
            @search.total.should == 16
            @search.results.size.should == 6
            @search.startrecord.should == 11
            @search.endrecord.should == 16
          end
        end
      end

      context "when we want X Bing results from page Y and there are none" do
        before do
          @search = WebSearch.new(@valid_options.merge(:page => 4))
          json = File.read(Rails.root.to_s + "/spec/fixtures/json/12total_2results.json")
          parsed = JSON.parse(json)
          JSON.stub!(:parse).and_return parsed
        end

        context "when there are Odie results" do
          before do
            IndexedDocument.destroy_all
            @affiliate.site_domains.create!(:domain => 'nps.gov')
            11.times { |x| @affiliate.indexed_documents.create!(:title => "government I LOVE AMERICA #{x}", :description => "government WE LOVE AMERICA #{x}", :url => "http://nps.gov/america#{x}.html", :last_crawl_status => IndexedDocument::OK_STATUS) }
            IndexedDocument.reindex
            Sunspot.commit
          end

          it "should subtract the total number of Bing results pages available and page into the Odie results" do
            @search.run
            @search.total.should == 31
            @search.results.size.should == 1
            @search.startrecord.should == 31
            @search.endrecord.should == 31
          end
        end
      end
    end
  end

  describe "#hits(response)" do
    context "when Bing reports a total > 0 but gives no results whatsoever" do
      before do
        @search = WebSearch.new(:affiliate => @affiliate)
        @response = mock("response")
        web = mock("web")
        @response.stub!(:web).and_return(web)
        web.stub!(:results).and_return(nil)
        web.stub!(:total).and_return(4000)
      end

      it "should return zero for the number of hits" do
        @search.send(:hits, @response).should == 0
      end
    end
  end

  describe "#as_json" do
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:search) { WebSearch.new(:query => 'obama', :affiliate => affiliate) }

    it "should generate a JSON representation of total, start and end records, and search results" do
      search.run
      json = search.to_json
      json.should =~ /total/
      json.should =~ /startrecord/
      json.should =~ /endrecord/
      json.should_not =~ /boosted_results/
      json.should_not =~ /spelling_suggestion/
    end

    context "when an error occurs" do
      before do
        search.run
        search.instance_variable_set(:@error_message, "Some error")
      end

      it "should output an error if an error is detected" do
        json = search.to_json
        json.should =~ /"error":"Some error"/
      end
    end

    context "when boosted contents are present" do
      before do
        affiliate.boosted_contents.create!(:title => "boosted obama content", :url => "http://example.com", :description => "description", :status => 'active', :publish_start_on => Date.current)
        BoostedContent.reindex
        Sunspot.commit
        search.run
      end

      it "should output boosted results" do
        json = search.to_json
        json.should =~ /boosted obama content/
      end
    end

    context "when Bing spelling suggestion is present" do
      before do
        search.instance_variable_set(:@spelling_suggestion, "spell it this way")
      end

      it "should output spelling suggestion" do
        json = search.to_json
        json.should =~ /spell it this way/
      end
    end
  end

  describe "#to_xml" do
    context "when error message exists" do
      let(:search) { WebSearch.new(:query => 'solar'*1000, :affiliate => affiliates(:basic_affiliate)) }

      it "should be included in the search result" do
        search.run
        search.to_xml.should =~ /<search><error>That is too long a word. Try using a shorter word.<\/error><\/search>/
      end

    end

    context "when there are search results" do
      let(:search) { WebSearch.new(:query => 'solar', :affiliate => affiliates(:basic_affiliate)) }
      it "should call to_xml on the result_hash" do
        hash = {}
        search.should_receive(:result_hash).and_return hash
        hash.should_receive(:to_xml).with({:indent => 0, :root => :search})
        search.to_xml
      end

    end
  end

  describe "#are_results_by_bing?" do
    context "when doing a normal search with normal results" do
      it "should return true" do
        search = WebSearch.new(:query => 'white house', :affiliate => affiliates(:basic_affiliate))
        search.run
        search.are_results_by_bing?.should be_true
      end
    end

    context "when the Bing results are empty and there are instead locally indexed results" do
      before do
        affiliate = affiliates(:non_existant_affiliate)
        affiliate.site_domains.create(:domain => "url.gov")
        affiliate.indexed_documents.create!(:url => 'http://some.url.gov/', :title => 'White House Indexed Doc', :description => 'This is an indexed document for the White House.', :body => "so tedious", :last_crawl_status => IndexedDocument::OK_STATUS)
        IndexedDocument.reindex
        Sunspot.commit
        @search = WebSearch.new(:query => 'white house', :affiliate => affiliate)
        @search.run
      end

      it "should return false" do
        @search.are_results_by_bing?.should be_false
      end
    end
  end

  describe ".results_present_for?(query, affiliate)" do
    before do
      @search = WebSearch.new(:affiliate => @affiliate, :query => "some term")
      WebSearch.stub!(:new).and_return(@search)
      @search.stub!(:run).and_return(nil)
    end

    context "when search results do not exist for a term/affiliate pair" do
      before do
        @search.stub!(:results).and_return([])
      end

      it "should return false" do
        WebSearch.results_present_for?("some term", @affiliate).should be_false
      end
    end

    context "when search results exist for a term/affiliate pair" do
      before do
        @search.stub!(:results).and_return([{'title' => 'First title', 'content' => 'First content'},
                                            {'title' => 'Second title', 'content' => 'Second content'}])
      end

      context 'when search engine does not have a spelling suggestion' do
        before do
          @search.stub!(:spelling_suggestion).and_return nil
        end

        it "should return true" do
          WebSearch.results_present_for?("some term", @affiliate).should be_true
        end
      end

      context "when search engine suggests a different spelling" do
        context "when it's a fuzzy match with the query term (i.e., identical except for highlights and some punctuation)" do
          before do
            @search.stub!(:spelling_suggestion).and_return "some-term"
          end

          it "should return true" do
            WebSearch.results_present_for?("some term", @affiliate).should be_true
          end
        end

        context "when it's not a fuzzy match with the query term" do
          before do
            @search.stub!(:spelling_suggestion).and_return "sum term"
          end

          it "should return false" do
            WebSearch.results_present_for?("some term", @affiliate).should be_false
          end
        end
      end
    end
  end
end
