require 'spec_helper'

describe LegacyImageSearch do
  fixtures :affiliates, :site_domains, :flickr_profiles

  describe '#new' do
    let(:affiliate) { affiliates(:usagov_affiliate) }

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
      let(:affiliate) { affiliates(:usagov_affiliate) }
      let(:noresults_search) { LegacyImageSearch.new(query: 'shuttle', affiliate: affiliate) }

      before do
        noresults_search.stub!(:search).and_return {}
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
          search_response.results = [Hashie::Rash.new(title: 'President Obama walks his unusual image daughters to school', url: "http://url1", thumbnail_url: "http://thumbnailurl1"), Hashie::Rash.new(title: 'POTUS gets in unusual image car.', url: "http://url2", thumbnail_url: "http://thumbnailurl2")]
          search_response.end_record = 2
        end
      end

      before do
        oasis_search = mock(OasisSearch)
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
        oasis_search = mock(OasisSearch)
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
      let(:search) { LegacyImageSearch.new(:query => 'white house', :affiliate => affiliates(:non_existent_affiliate)) }

      it "should set total" do
        search.run
        search.total.should == 4340000
      end

      it "should ignore results with missing Thumbnail data" do
        search.run
        search.results.size.should == 9
      end

      it "includes original image meta-data" do
        search.run
        result = search.results.first
        result["title"].should == "White House, Washington D.C."
        result["Url"].should == "http://biglizards.net/blog/archives/2008/08/"
        result["DisplayUrl"].should == "http://biglizards.net/blog/archives/2008/08/"
        result["Width"].should == 391
        result["Height"].should == 428
        result["FileSize"].should == 37731
        result["ContentType"].should == "image/jpeg"
        result["MediaUrl"].should == "http://biglizards.net/Graphics/ForegroundPix/White_House.JPG"
      end

      it "includes thumbnail meta-data" do
        search.run
        result = search.results.first
        result["Thumbnail"]["Url"].should == "http://ts1.mm.bing.net/images/thumbnail.aspx?q=1581721453740&id=869b85a01b58c5a200496285e0144df1"
        result["Thumbnail"]["FileSize"].should == 4719
        result["Thumbnail"]["Width"].should == 146
        result["Thumbnail"]["Height"].should == 160
        result["Thumbnail"]["ContentType"].should == "image/jpeg"
      end

    end
  end

end
