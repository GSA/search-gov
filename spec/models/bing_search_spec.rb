require 'spec_helper'

describe BingSearch do
  describe '.search_for_url_in_bing' do
    context 'when url does not exist in Bing' do
      let(:url) { 'http://www.usa.gov/system/selfservice.controller?ARTICLE_ID=10619' }
      let(:url_without_query) { 'http://www.usa.gov/system/selfservice.controller' }

      before do
        BingSearch.should_receive(:url_in_bing).with(url)
        BingSearch.should_receive(:url_in_bing).with(url_without_query)
      end

      specify { BingSearch.search_for_url_in_bing(url).should be_nil }
    end

    context 'when url exists in Bing' do
      let(:url) { 'https://www.whitehouse.gov/blog/issues/women?article=100#main_content' }
      let(:url_without_fragment) { 'https://www.whitehouse.gov/blog/issues/women?article=100' }
      let(:normalized_url) { 'whitehouse.gov/blog/issues/women?article=100' }

      before { BingSearch.should_receive(:url_in_bing).with(url_without_fragment).and_return(normalized_url) }

      specify { BingSearch.search_for_url_in_bing(url).should == normalized_url }
    end

    context 'when there is Exception' do
      before do
        URI.should_receive(:parse).and_raise(Exception)
        Rails.logger.should_receive(:warn).with(/^Trouble determining if URL/)
      end

      specify { BingSearch.search_for_url_in_bing('http://www.usa.gov').should be_nil }
    end
  end

  describe '.normalized_url(url)' do
    context "when URL is poorly formed" do
      it 'should return nil' do
        BingSearch.normalized_url("http://www.whitehouse.gov/htdata/CMSP/LegAtlas/Cases/Clinton B. Craft, 6 O.R.W. 150 (1990); Craft v. Nat'l Park Serv., 34 F.3d 918 (9th Cir. 1994)/Craft v. Nat'l Park Serv., 34 F. 3d 918 (9th Cir. 1994).pdf").should be_nil
      end
    end
  end

  describe '.url_in_bing' do
    let!(:bing_search) { BingSearch.new }

    context 'when url exists in BingUrl' do
      let(:url) { 'https://www.whitehouse.gov/blog/issues/women?article=100#main_content' }
      let(:normalized_url) { 'whitehouse.gov/blog/issues/women?article=100' }
      let!(:bing_url) { BingUrl.create!(:normalized_url => normalized_url) }

      it 'should return url without scheme and fragment' do
        BingUrl.should_receive(:find_by_normalized_url).with(normalized_url).and_return(bing_url)
        BingSearch.url_in_bing(url).should == normalized_url
      end
    end

    context 'when url exists in BingSearch' do
      let(:url) { 'http://www.clinicaltrials.gov/ct2/show/NCT01308762' }
      let(:normalized_url) { 'clinicaltrials.gov/ct2/show/NCT01308762' }
      let(:response) do
        raw = "{\"SearchResponse\":{\"Version\":\"2.2\",\"Query\":{\"SearchTerms\":\"http:\\/\\/www.clinicaltrials.gov\\/ct2\\/show\\/NCT01308762\"},\"Web\":{\"Total\":1,\"Offset\":0,\"Results\":[{\"Title\":\"A Clinical Study, to Evaluate the Safety and Tolerability of ...\",\"Description\":\"A Clinical Study, to Evaluate the Safety and Tolerability of Intradermal IMM-101 in Adult Melanoma Cancer Patients\",\"Url\":\"http:\\/\\/clinicaltrials.gov\\/ct2\\/show\\/NCT01308762\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=%22http+www+clinicaltrials+gov+ct2+show+nct01308762%22&d=4927994596163714&w=a3798854,eee0c025\",\"DisplayUrl\":\"clinicaltrials.gov\\/ct2\\/show\\/NCT01308762\",\"DateTime\":\"2012-08-20T14:14:00Z\"}]}}}"
        json = JSON.parse raw
        rashie = Hashie::Rash.new json
        rashie.search_response
      end

      it 'should return url without scheme and fragment' do
        BingUrl.should_receive(:find_by_normalized_url).with(normalized_url).and_return(nil)
        BingSearch.should_receive(:new).and_return bing_search
        bing_search.should_receive(:query).
          with(url, anything, anything, anything, anything, anything).
          and_return(response)
        BingSearch.url_in_bing(url).should == normalized_url
      end
    end

    context 'when url does not exist in BingSearch' do
      let(:url) { 'http://www.clinicaltrials.gov/ct2/show/NCT01308762' }
      let(:normalized_url) { 'clinicaltrials.gov/ct2/show/NCT01308762' }
      let(:response) do
        raw = "{\"SearchResponse\":{\"Version\":\"2.2\",\"Query\":{\"SearchTerms\":\"http:\\/\\/www.clinicaltrials.gov\\/ct2\\/show\\/NCT01308762\"},\"Web\":{\"Total\":1,\"Offset\":0,\"Results\":[{\"Title\":\"A Clinical Study, to Evaluate the Safety and Tolerability of ...\",\"Description\":\"A Clinical Study, to Evaluate the Safety and Tolerability of Intradermal IMM-101 in Adult Melanoma Cancer Patients\",\"Url\":\"http:\\/\\/clinicaltrials.gov\\/ct2\\/show\\/OtherNCT01308762\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=%22http+www+clinicaltrials+gov+ct2+show+nct01308762%22&d=4927994596163714&w=a3798854,eee0c025\",\"DisplayUrl\":\"clinicaltrials.gov\\/ct2\\/show\\/OtherNCT01308762\",\"DateTime\":\"2012-08-20T14:14:00Z\"}]}}}"
        json = JSON.parse raw
        rashie = Hashie::Rash.new json
        rashie.search_response
      end

      it 'should return nil' do
        BingUrl.should_receive(:find_by_normalized_url).with(normalized_url).and_return(nil)
        BingSearch.should_receive(:new).and_return bing_search
        bing_search.should_receive(:query).
          with('http://www.clinicaltrials.gov/ct2/show/NCT01308762', anything, anything, anything, anything, anything).
          and_return(response)
        BingSearch.url_in_bing(url).should be_nil
      end
    end

    context 'when there is Exception' do
      let(:url) { 'http://www.clinicaltrials.gov/ct2/show/NCT01308762' }

      before { URI.should_receive(:parse).and_raise(Exception) }

      specify { BingSearch.url_in_bing(url).should be_nil }
    end
  end
end
