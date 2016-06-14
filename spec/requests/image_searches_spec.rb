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
        json_response['error'].should == 'Please enter a search term in the box above.'
      end
    end
  end

  context 'when site is bing image search enabled' do
    let(:affiliate) { affiliates(:bing_image_search_enabled_affiliate) }

    before do
      get '/search/images.json', { affiliate: affiliate.name, query: 'white house' }
    end

    it 'renders JSON response' do
      json_response = JSON.parse(response.body)
      expect(json_response['total']).to be > 10000
      expect(json_response['startrecord']).to eq 1
      expect(json_response['endrecord']).to eq 20
      expect(json_response['results'].count).to eq 20

      image = json_response['results'].first
      expect(image['title']).to match(/White House/)
      expect(image['media_url']).to match(URI.regexp)
      expect(image['url']).to match(URI.regexp)
      expect(image['display_url']).to match(/^www\./)
      expect(image['width']).to be_an Integer
      expect(image['height']).to be_an Integer
      expect(image['file_size']).to be_an Integer
      expect(image['content_type']).to match(/image/)
      expect(image['thumbnail'].keys).to match_array(%w{ url content_type width height file_size })
    end
  end
end
