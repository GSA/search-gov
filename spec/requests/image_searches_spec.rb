require 'spec_helper'

describe '/search/images' do
  fixtures :affiliates, :instagram_profiles

  context 'when site is not bing image search enabled' do
    let(:affiliate) { affiliates(:usagov_affiliate) }
    let(:search_engine_response) do
      SearchEngineResponse.new do |search_response|
        search_response.total = 2
        search_response.start_record = 1
        search_response.results = [Hashie::Rash.new(title: 'white house photo 1', url: "http://www.flickr.com/photos/35591378@N03/2", thumbnail_url: "http://thumbnailurl1"), Hashie::Rash.new(title: 'white house photo 2', url: "http://www.flickr.com/photos/35591378@N03/2", thumbnail_url: "http://thumbnailurl2")]
        search_response.end_record = 2
      end
    end

    before do
      affiliate.instagram_profiles << instagram_profiles(:whitehouse)
      oasis_search = mock(OasisSearch)
      OasisSearch.stub(:new).and_return oasis_search
      oasis_search.stub(:execute_query).and_return search_engine_response
    end

    context 'when query is present' do
      before do
        get '/search/images.json', { affiliate: affiliate.name, query: 'white house' }
      end

      it 'responds with search results from Oasis' do
        json_response = JSON.parse(response.body)
        json_response['total'].should == 2
        json_response['startrecord'].should == 1
        json_response['endrecord'].should == 2

        json_response['results'].each do |r|
          r['title'].should start_with('white house photo')
          r['url'].should start_with('http://www.flickr.com/photos/35591378@N03/')
        end
      end
    end

    context 'when query is blank' do
      before do
        get '/search/images.json', { affiliate: affiliate.name, query: ' ' }
      end

      it 'responds with error message' do
        json_response = JSON.parse(response.body)
        json_response['error'].should == 'Please enter search term(s)'
      end
    end
  end

  context 'when site is bing image search enabled' do
    let(:affiliate) { affiliates(:bing_image_search_enabled_affiliate) }
    let(:expected_response_body) { Rails.root.join('spec/fixtures/json/expected_bing_image_search_results.json').read }

    before do
      get '/search/images.json', { affiliate: affiliate.name, query: 'white house' }
    end

    it 'renders JSON response' do
      json_response = JSON.parse(response.body)
      json_response['total'].should == 4340000
      json_response['startrecord'].should == 1
      json_response['endrecord'].should == 10

      expected_json_response = JSON.parse(expected_response_body)
      json_response['results'][0].should == expected_json_response['results'][0]
      json_response['results'][1].should == expected_json_response['results'][1]
      json_response['results'][2].should == expected_json_response['results'][2]
    end
  end
end
