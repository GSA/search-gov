# coding: utf-8
shared_examples "a search engine" do
  describe ".new" do
    it 'should set up API connection' do
      search_engine = described_class.new
      search_engine.api_endpoint.should == described_class::API_ENDPOINT
    end
  end

  describe '#execute_query' do
    context 'when something goes wrong' do
      subject { described_class.new(query: "taxes") }

      it 'should raise an error' do
        subject.stub!(:api_connection).and_raise Exception.new('uh oh')
        expect { subject.execute_query }.to raise_error(SearchEngine::SearchError, 'uh oh')
      end
    end

    context 'when highlighting is enabled' do
      let(:highlight_search) { described_class.new(query: "highlight enabled", enable_highlighting: true) }

      it "should return a normalized response with highlighted results" do
        normalized_response = highlight_search.execute_query
        normalized_response.start_record.should == 1
        normalized_response.end_record.should == 10
        normalized_response.total.should == 1940000
        normalized_response.results.first.title.should == "Publication 590 (2011), Individual Retirement Arrangements (\xEE\x80\x80IRAs\xEE\x80\x81)"
        normalized_response.results.first.content.should == "Examples — Worksheet for Reduced \xEE\x80\x80IRA\xEE\x80\x81 Deduction for 2011; What if You Inherit an \xEE\x80\x80IRA\xEE\x80\x81? Treating it as your own. Can You Move Retirement Plan Assets?"
        normalized_response.results.first.unescaped_url.should == "http:\/\/www.irs.gov\/publications\/p590\/index.html"
      end
    end

    context 'when highlighting is disabled' do
      let(:non_highlight_search) { described_class.new(query: "no highlighting", enable_highlighting: false, offset: 11, per_page: 25) }

      it "should return a normalized response without highlighted results" do
        normalized_response = non_highlight_search.execute_query
        normalized_response.start_record.should == 1
        normalized_response.end_record.should == 10
        normalized_response.total.should == 1940000
        normalized_response.results.first.title.should == "Publication 590 (2011), Individual Retirement Arrangements (IRAs)"
        normalized_response.results.first.content.should == "Examples — Worksheet for Reduced IRA Deduction for 2011; What if You Inherit an IRA? Treating it as your own. Can You Move Retirement Plan Assets?"
        normalized_response.results.first.unescaped_url.should == "http:\/\/www.irs.gov\/publications\/p590\/index.html"
      end
    end

    context "when Spanish locale is specified" do
      let(:spanish_search) { described_class.new(query: "casa blanca") }

      before do
        I18n.locale = :es
      end

      it "should pass a Spanish language filter to Google" do
        spanish_search.execute_query
      end

      after do
        I18n.locale = I18n.default_locale
      end
    end

    context "when non-Spanish locale is specified" do
      let(:english_search) { described_class.new(query: "english") }

      it "should pass an English language filter to Google" do
        english_search.execute_query
      end
    end

    context "when the search engine returns zero results" do
      let(:search) { described_class.new(query: "no_results") }

      it "should have 0 results" do
        search_engine_response = search.execute_query
        search_engine_response.results.should be_empty
        search_engine_response.total.should be_zero
      end
    end

    context 'when a spelling suggestion is available' do
      let(:search) { described_class.new(query: "electro coagulation") }

      it "should set a spelling suggestion" do
        search_engine_response = search.execute_query
        search_engine_response.spelling_suggestion.should == 'electrocoagulation'
      end
    end
  end

end