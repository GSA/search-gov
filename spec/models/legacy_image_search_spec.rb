require 'spec_helper'

describe LegacyImageSearch do
  fixtures :affiliates, :site_domains, :flickr_profiles
  let(:affiliate) { affiliates(:usagov_affiliate) }

  describe "#run" do
    context "when there are no Bing/Google or Flickr results" do
      let(:noresults_search) { LegacyImageSearch.new(query: 'shuttle', affiliate: affiliate) }

      before do
        allow(noresults_search).to receive(:search)
      end

      it "should assign a nil module_tag" do
        noresults_search.run
        expect(noresults_search.module_tag).to be_nil
      end
    end

    context 'when the affiliate has no Bing/Google results, but has images from Oasis' do
      let(:non_affiliate) { affiliates(:non_existent_affiliate) }
      let(:search_engine_response) do
        SearchEngineResponse.new do |search_response|
          search_response.total = 2
          search_response.start_record = 1
          search_response.results = [Hashie::Mash::Rash.new(title: 'President Obama walks his unusual image daughters to school', url: "http://url1", thumbnail_url: "http://thumbnailurl1"), Hashie::Mash::Rash.new(title: 'POTUS gets in unusual image car.', url: "http://url2", thumbnail_url: "http://thumbnailurl2")]
          search_response.end_record = 2
        end
      end

      before do
        oasis_search = double(OasisSearch)
        allow(OasisSearch).to receive(:new).and_return oasis_search
        allow(oasis_search).to receive(:execute_query).and_return search_engine_response
      end

      it 'should fill the results with the flickr photos' do
        search = LegacyImageSearch.new(query: 'unusual image', affiliate: non_affiliate)
        search.run
        expect(search.results).not_to be_empty
        expect(search.total).to eq(2)
        expect(search.module_tag).to eq('OASIS')
        expect(search.results.first['title']).to eq('President Obama walks his unusual image daughters to school')
        expect(search.results.last['title']).to eq('POTUS gets in unusual image car.')
      end
    end

    context 'when the affiliate has no Bing/Google/oasis results' do
      let(:non_affiliate) { affiliates(:non_existent_affiliate) }
      let(:search_engine_response) do
        SearchEngineResponse.new do |search_response|
          search_response.total = 0
          search_response.results = []
        end
      end

      before do
        oasis_search = double(OasisSearch)
        allow(OasisSearch).to receive(:new).and_return oasis_search
        allow(oasis_search).to receive(:execute_query).and_return search_engine_response
      end

      it 'should fill the results with the flickr photos' do
        search = LegacyImageSearch.new(query: 'ubama', affiliate: non_affiliate)
        search.run
        expect(search.results).to be_empty
        expect(search.total).to eq(0)
      end
    end

    context 'when there are Bing/Google results' do
      let(:search) { LegacyImageSearch.new(:query => 'white house', :affiliate => affiliate) }

      before { search.run }

      it "should set total" do
        expect(search.total).to be > 100
      end

      it "includes original image meta-data" do
        result = search.results.first
        expect(result["title"]).to match /White House/i
        expect(result["Url"]).to match(URI.regexp)
        expect(result["DisplayUrl"]).to match(/(\A\z)|(\A((http|https):\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?([\/].*)?\z)/ix)
        expect(result["Width"]).to be_an Integer
        expect(result["Height"]).to be_an Integer
        expect(result["FileSize"]).to be_an Integer
        expect(result["ContentType"]).to match(/^image\/\w+/)
        expect(result["MediaUrl"]).to match(URI.regexp)
      end

      it "includes thumbnail meta-data" do
        result = search.results.first
        expect(result["Thumbnail"]["Url"]).to match(URI.regexp)
        expect(result["Thumbnail"]["FileSize"]).to be nil
        expect(result["Thumbnail"]["Width"]).to be_an Integer
        expect(result["Thumbnail"]["Height"]).to be_an Integer
        expect(result["Thumbnail"]["ContentType"]).to be nil
      end
    end
  end

end
