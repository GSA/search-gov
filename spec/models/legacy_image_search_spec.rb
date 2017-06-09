require 'spec_helper'

describe LegacyImageSearch do
  fixtures :affiliates, :site_domains, :flickr_profiles
  let(:affiliate) { affiliates(:usagov_affiliate) }

  describe '#new' do
    context 'when the search engine is Azure' do
      before { affiliate.search_engine = 'Azure' }

      it 'searches using Azure engine' do
        HostedAzureImageEngine.should_receive(:new).
          with(hash_including(language: 'en',
                              offset: 0,
                              per_page: 20,
                              query: 'government (site:gov OR site:mil)'))

        described_class.new query: 'government', affiliate: affiliate
      end
    end
  end

  describe "#run" do
    context "when there are no Bing/Google or Flickr results" do
      let(:noresults_search) { LegacyImageSearch.new(query: 'shuttle', affiliate: affiliate) }

      before do
        noresults_search.stub(:search)
      end

      it "should assign a nil module_tag" do
        noresults_search.run
        noresults_search.module_tag.should be_nil
      end
    end

    context 'when the affiliate has no Bing/Google results, but has Flickr/Instagram images from Oasis' do
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
        OasisSearch.stub(:new).and_return oasis_search
        oasis_search.stub(:execute_query).and_return search_engine_response
      end

      it 'should fill the results with the flickr photos' do
        search = LegacyImageSearch.new(query: 'unusual image', affiliate: non_affiliate)
        search.run
        search.results.should_not be_empty
        search.total.should == 2
        search.module_tag.should == 'OASIS'
        search.results.first['title'].should == 'President Obama walks his unusual image daughters to school'
        search.results.last['title'].should == 'POTUS gets in unusual image car.'
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
        OasisSearch.stub(:new).and_return oasis_search
        oasis_search.stub(:execute_query).and_return search_engine_response
      end

      it 'should fill the results with the flickr photos' do
        search = LegacyImageSearch.new(query: 'ubama', affiliate: non_affiliate)
        search.run
        search.results.should be_empty
        search.total.should == 0
      end
    end

    context 'when there are Bing/Google results' do
      let(:search) { LegacyImageSearch.new(:query => 'white house', :affiliate => affiliate) }

      before { search.run }

      it "should set total" do
        search.total.should be > 100
      end

      it "includes original image meta-data" do
        result = search.results.first
        result["title"].should match /White House/i
        result["Url"].should match(URI.regexp)
        result["DisplayUrl"].should match(/(\A\z)|(\A((http|https):\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?([\/].*)?\z)/ix)
        result["Width"].should be_an Integer
        result["Height"].should be_an Integer
        result["FileSize"].should be_an Integer
        result["ContentType"].should == "image/jpeg"
        result["MediaUrl"].should match(URI.regexp)
      end

      it "includes thumbnail meta-data" do
        result = search.results.first
        result["Thumbnail"]["Url"].should match(URI.regexp)
        result["Thumbnail"]["FileSize"].should be nil
        result["Thumbnail"]["Width"].should be_an Integer
        result["Thumbnail"]["Height"].should be_an Integer
        result["Thumbnail"]["ContentType"].should be nil
      end
    end
  end

end
