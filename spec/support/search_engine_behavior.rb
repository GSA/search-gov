# coding: utf-8

shared_examples "a web search engine" do
  describe ".new" do
    it 'should set up API connection' do
      search_engine = described_class.new
      expect(search_engine.api_endpoint).to eq(described_class::API_ENDPOINT)
    end
  end

  describe '#execute_query' do
    subject(:search) { described_class.new(query: "taxes") }
    context 'when something goes wrong' do
      before { allow(search.api_connection).to receive(:get).and_raise 'uh oh' }

      it 'should raise an error' do
        expect { search.execute_query }.to raise_error(SearchEngine::SearchError, 'uh oh')
      end
    end

    context 'when highlighting is enabled' do
      let(:highlight_search) { described_class.new(query: "white house", enable_highlighting: true) }

      it "should return a normalized response with highlighted results" do
        normalized_response = highlight_search.execute_query
        expect(normalized_response.start_record).to eq 1
        expect(normalized_response.total).to be > 1000
        expect(normalized_response.results.map(&:title).join).to match(/\xEE\x80\x80White House\xEE\x80\x81/)
        expect(normalized_response.results.map(&:content).join).to match(/\xEE\x80\x80White House\xEE\x80\x81/)
        expect(normalized_response.results.first.unescaped_url).to match(URI.regexp)
      end
    end

    context 'when highlighting is disabled' do
      let(:non_highlight_search) do
        described_class.new(query: "white house", enable_highlighting: false)
      end

      it "should return a normalized response without highlighted results" do
        normalized_response = non_highlight_search.execute_query
        expect(normalized_response.total).to be > 1000
        expect(normalized_response.results.first.title).to match /White House/
        expect(normalized_response.results.map(&:title).join).to_not match(/\xEE\x80\x80White House\xEE\x80\x81/)
        expect(normalized_response.results.map(&:content).join).to_not match(/\xEE\x80\x80.+\xEE\x80\x81/)
        expect(normalized_response.results.first.unescaped_url).to match(URI.regexp)
      end
    end

    context 'when an offset is specified' do
      let(:search) { described_class.new(query: "anything", offset: 11, limit: 10) }

      it 'returns the offset results' do
        normalized_response = search.execute_query
        expect(normalized_response.start_record).to eq 12
        expect(normalized_response.end_record).to eq 21
      end
    end

    context "when Spanish locale is specified" do
      let(:spanish_search) { described_class.new(query: "casa blanca") }

      before do
        I18n.locale = :es
      end

      it "should pass a Spanish language filter" do
        spanish_search.execute_query
      end

      after do
        I18n.locale = I18n.default_locale
      end
    end

    context "when Chinese locale is specified" do
      let(:chinese_search) { described_class.new(query: "中国") }

      before do
        I18n.locale = :zh
      end

      it "should pass a Simplified Chinese language filter" do
        chinese_search.execute_query
      end

      after do
        I18n.locale = I18n.default_locale
      end
    end

    context "when Google unsupported locale is specified" do
      let(:creole_search) { described_class.new(query: "tradiksyon") }

      before do
        I18n.locale = :ht
      end

      it "should pass no language filter to Google" do
        creole_search.execute_query
      end

      after do
        I18n.locale = I18n.default_locale
      end
    end

    context "when English locale is specified" do
      let(:english_search) { described_class.new(query: "english") }

      it "should pass an English language filter to Google" do
        english_search.execute_query
      end
    end

    context "when the search engine returns zero results" do
      let(:search) { described_class.new(query: "'65d86996b6eceb05d2272aea9cadd10d'") }

      it "should have 0 results" do
        search_engine_response = search.execute_query
        expect(search_engine_response.results).to be_empty
        expect(search_engine_response.total).to be_zero
      end
    end

    context 'when a spelling suggestion is available' do
      let(:search) { described_class.new(query: "sailing dingies") }

      it "should set a spelling suggestion" do
        search_engine_response = search.execute_query
        expect(search_engine_response.spelling_suggestion).to eq('sailing dinghies')
      end
    end
  end
end

shared_examples "an image search" do
  let(:image_search_params) do
    {
      offset: 20,
      limit: 10,
      query: 'agncy (site:nasa.gov)',
    }
  end
  let(:image_search) { described_class.new(image_search_params) }
  let(:search_response) { image_search.execute_query }

  describe '#execute_query' do
    it 'returns results' do
      expect(search_response.start_record).to eq 21
      expect(search_response.end_record).to eq 30
      expect(search_response.total).to be > 100
    end

    it 'returns images' do
      image = search_response.results.first
      expect(search_response.results.map(&:title).join).to match(%r{agency}i)
      expect(image.title).to be_a String
      expect(image.width).to be_an Integer
      expect(image.height).to be_an Integer
      expect(image.file_size).to be_an Integer
      expect(image.content_type).to match(/image/)
      expect(image.url).to match(URI.regexp)
      expect(image.display_url).to be_a String
      expect(image.media_url).to match(URI.regexp)
      expect(image.file_size).to be > 0
      expect(image.width).to be > 0
      expect(image.height).to be > 0

      thumbnail = image.thumbnail
      expect(thumbnail.url).to match(URI.regexp)
      expect(thumbnail.height).to be_an Integer
      expect(thumbnail.width).to be_an Integer
    end
  end
end
