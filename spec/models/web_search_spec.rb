# coding: utf-8
require 'spec_helper'

describe WebSearch do
  fixtures :affiliates, :site_domains

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
      search = WebSearch.new(@valid_options)
      search.affiliate.should == @affiliate
    end

    it "should not require a query" do
      WebSearch.new({affiliate: @affiliate})
    end

    it 'should ignore invalid params' do
      search = WebSearch.new(@valid_options.merge(page: {foo: 'bar'}))
      search.page.should == 1
    end

    it 'should ignore params outside the allowed range' do
      search = WebSearch.new(@valid_options.merge(page: -1))
      search.page.should == Search::DEFAULT_PAGE
    end

    it 'should set matching site limits' do
      @affiliate.site_domains.create!(domain: 'foo.com')
      @affiliate.site_domains.create!(domain: 'bar.gov')
      search = WebSearch.new({query: 'government', affiliate: @affiliate, site_limits: 'foo.com/subdir1 foo.com/subdir2 include3.gov'})
      search.matching_site_limits.should == %w(foo.com/subdir1 foo.com/subdir2)
    end

    context 'when affiliate has scope keywords' do
      before do
        @affiliate.scope_keywords = 'foo,bar, blat'
      end

      context 'when user sends in query-or param in advanced search' do
        it 'should add them to user-specified query-or param' do
          search = WebSearch.new(@valid_options.merge(query_or: 'baz bar'))
          search.query.should == 'government (baz OR bar OR foo OR blat)'
        end
      end

      context 'when query-or param is blank' do
        it 'should use the scope keywords as the query-or param' do
          search = WebSearch.new(@valid_options)
          search.query.should == 'government (foo OR bar OR blat)'
        end
      end
    end

  end

  describe "instrumenting search engine calls" do
    context 'when Bing is the engine' do
      before do
        @affiliate = affiliates(:usagov_affiliate)
        @valid_options = {query: 'government', affiliate: @affiliate}
        bing_search = BingWebSearch.new(@valid_options)
        BingWebSearch.stub!(:new).and_return bing_search
        bing_search.stub!(:execute_query).and_return
      end

      it "should instrument the call to the search engine with the proper action.service namespace and query param hash" do
        @affiliate.search_engine.should == 'Bing'
        ActiveSupport::Notifications.should_receive(:instrument).
          with("bing_web_search.usasearch", hash_including(query: hash_including(term: 'government')))
        WebSearch.new(@valid_options).send(:search)
      end
    end

    context 'when Google is the engine' do
      before do
        @affiliate = affiliates(:basic_affiliate)
        @valid_options = {query: 'government', affiliate: @affiliate}
        google_search = GoogleWebSearch.new(@valid_options)
        GoogleWebSearch.stub!(:new).and_return google_search
        google_search.stub!(:execute_query).and_return
      end

      it "should instrument the call to the search engine with the proper action.service namespace and query param hash" do
        @affiliate.search_engine.should == 'Google'
        ActiveSupport::Notifications.should_receive(:instrument).
          with("google_web_search.usasearch", hash_including(query: hash_including(term: 'government')))
        WebSearch.new(@valid_options).send(:search)
      end
    end
  end

  describe "#run" do

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

      let(:affiliate) { affiliates(:basic_affiliate) }

      it "should default to page 1 if no valid page number was specified" do
        WebSearch.new({query: 'government', affiliate: affiliate}).page.should == Search::DEFAULT_PAGE
        WebSearch.new({query: 'government', affiliate: affiliate, page: ''}).page.should == Search::DEFAULT_PAGE
        WebSearch.new({query: 'government', affiliate: affiliate, page: 'string'}).page.should == Search::DEFAULT_PAGE
      end

      it "should set the page number" do
        search = WebSearch.new({query: 'government', affiliate: affiliate, page: 2})
        search.page.should == 2
      end
    end

    describe "logging module impressions" do
      before do
        @search = WebSearch.new({query: 'government', affiliate: affiliates(:basic_affiliate)})
        @search.stub!(:search)
        @search.stub!(:handle_response)
        @search.stub!(:populate_additional_results)
        @search.stub!(:module_tag).and_return 'BWEB'
        @search.stub!(:spelling_suggestion).and_return 'foo'
        @search.stub!(:med_topic).and_return 'foo'
        @search.stub!(:jobs).and_return [1, 2, 3]
        @search.stub!(:has_related_searches?).and_return true
        @search.stub!(:has_featured_collections?).and_return true
        @search.stub!(:has_boosted_contents?).and_return true
        @search.stub!(:has_forms?).and_return true
        @search.stub!(:has_news_items?).and_return true
        @search.stub!(:has_video_news_items?).and_return true
        @search.stub!(:has_tweets?).and_return true
        @search.stub!(:has_photos?).and_return true
      end

      it "should assign module_tag to BWEB" do
        @search.run
        @search.module_tag.should == 'BWEB'
      end

      it "should log info about the query" do
        all_modules = %w{BWEB OVER BSPEL SREL NEWS VIDS FORM BBG BOOS MEDL JOBS TWEET PHOTO}
        QueryImpression.should_receive(:log).with(:web, affiliates(:basic_affiliate).name, 'government', all_modules)
        @search.run
      end
    end

    context "when the affiliate has no Bing/Google results, but has indexed documents" do
      before do
        @non_affiliate = affiliates(:non_existent_affiliate)
        @non_affiliate.site_domains.create(:domain => "nonsense.com")
        @non_affiliate.indexed_documents.destroy_all
        1.upto(15) do |index|
          @non_affiliate.indexed_documents << IndexedDocument.new(:title => "Indexed Result no_result #{index}",
                                                                  :url => "http://nonsense.com/#{index}.html",
                                                                  :description => 'This is an indexed result no_result.',
                                                                  :last_crawl_status => IndexedDocument::OK_STATUS)
        end
        IndexedDocument.reindex
        Sunspot.commit
        @non_affiliate.indexed_documents.size.should == 15
        IndexedDocument.search_for('indexed', @non_affiliate, nil).total.should == 15
      end

      it "should fill the results with the Odie docs" do
        search = WebSearch.new(:query => 'no_results', :affiliate => @non_affiliate)
        search.run
        search.total.should == 15
        search.startrecord.should == 1
        search.endrecord.should == 10
        search.results.first['unescapedUrl'].should == "http://nonsense.com/1.html"
        search.results.last['unescapedUrl'].should == "http://nonsense.com/10.html"
        search.module_tag.should == 'AIDOC'
      end

    end

    context "when affiliate has no Bing/Google results and IndexedDocuments search returns nil" do
      before do
        @non_affiliate = affiliates(:non_existent_affiliate)
        @non_affiliate.boosted_contents.destroy_all
        IndexedDocument.stub!(:search_for).and_return nil
        @search = WebSearch.new(:query => 'no_results', :affiliate => @non_affiliate)
      end

      it "should return a search with a zero total" do
        @search.run
        @search.total.should == 0
        @search.results.should_not be_nil
        @search.results.should be_empty
        @search.startrecord.should be_nil
        @search.endrecord.should be_nil
      end

      it "should still return true when searching" do
        @search.run.should be_true
      end

      it "should populate additional results" do
        @search.should_receive(:populate_additional_results).and_return true
        @search.run
      end

    end

    context "when affiliate has no Bing/Google results and there is an orphan document in the Odie index" do
      before do
        @non_affiliate = affiliates(:non_existent_affiliate)
        @non_affiliate.indexed_documents.destroy_all
        IndexedDocument.reindex
        odie = @non_affiliate.indexed_documents.create!(:title => "PDF Title", :description => "PDF Description", :url => 'http://nonsense.gov/pdf1.pdf', :doctype => 'pdf', :last_crawl_status => IndexedDocument::OK_STATUS)
        Sunspot.commit
        odie.delete
        IndexedDocument.solr_search_ids { with :affiliate_id, affiliates(:non_existent_affiliate).id }.first.should == odie.id
      end

      it "should return with zero results" do
        search = WebSearch.new(:query => 'no_results', :affiliate => @non_affiliate)
        search.run
        search.results.should be_blank
      end

      after do
        IndexedDocument.reindex
      end
    end

    describe "ODIE backfill" do
      context "when we want X Bing/Google results from page Y and there are X of them" do
        before do
          @search = WebSearch.new(:query => 'english', :affiliate => affiliates(:non_existent_affiliate))
          @search.run
        end

        it "should return the X Bing/Google results" do
          @search.total.should == 1940000
          @search.results.size.should == 10
          @search.startrecord.should == 1
          @search.endrecord.should == 10
        end
      end

      context "when we want X Bing/Google results from page Y and there are 0 <= n < X of them" do
        before do
          @affiliate = affiliates(:non_existent_affiliate)
          @search = WebSearch.new(:query => 'fewer', :affiliate => @affiliate, :page => 2)
        end

        context "when there are Odie results" do
          before do
            @affiliate.indexed_documents.create!(:title => 'fewer I LOVE AMERICA', :description => 'fewer WE LOVE AMERICA', :url => 'http://nonsense.gov/america.html', :last_crawl_status => IndexedDocument::OK_STATUS)
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

          it "should return the X Bing/Google results" do
            @search.run
            @search.total.should == 16
            @search.results.size.should == 6
            @search.startrecord.should == 11
            @search.endrecord.should == 16
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
      json.should =~ /total/
      json.should =~ /startrecord/
      json.should =~ /endrecord/
      json.should =~ /results/
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
        affiliate.boosted_contents.create!(:title => "boosted english content", :url => "http://nonsense.gov",
                                           :description => "english description", :status => 'active', :publish_start_on => Date.current)
        BoostedContent.reindex
        Sunspot.commit
        search.run
      end

      it "should output boosted results" do
        json = search.to_json
        json.should =~ /boosted english content/
      end
    end

    context "when spelling suggestion is present" do
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
    let(:affiliate) { affiliates(:non_existent_affiliate) }
    let(:search) { WebSearch.new(:query => 'english', :affiliate => affiliate) }

    it "should generate a XML representation of total, start and end records, and search results" do
      search.run
      xml = search.to_xml
      xml.should =~ /total/
      xml.should =~ /startrecord/
      xml.should =~ /endrecord/
      xml.should =~ /results/
    end

    context "when an error occurs" do
      before do
        search.run
        search.instance_variable_set(:@error_message, "Some error")
      end

      it "should output an error if an error is detected" do
        xml = search.to_xml
        xml.should =~ /Some error/
      end
    end

  end

  describe ".results_present_for?(query, affiliate)" do
    before do
      @affiliate = affiliates(:non_existent_affiliate)
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

  describe "helper 'has' methods" do
    let(:search) { WebSearch.new(:query => 'english', :affiliate => affiliates(:non_existent_affiliate)) }

    it 'should raise an error when no helper can be found' do
      lambda { search.not_here }.should raise_error(NoMethodError)
    end
  end
end
