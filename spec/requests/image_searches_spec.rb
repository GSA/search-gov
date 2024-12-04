require 'spec_helper'

describe '/search/images' do
  fixtures :affiliates, :flickr_profiles

  context 'when site is not bing image search enabled' do
    let(:affiliate) { affiliates(:usagov_affiliate) }
    let(:search_engine_response) do
      SearchEngineResponse.new do |search_response|
        search_response.total = 2
        search_response.start_record = 1
        search_response.results = [Hashie::Mash::Rash.new(title: 'white house photo 1', url: 'http://www.flickr.com/photos/35591378@N03/2', thumbnail_url: 'http://thumbnailurl1'), Hashie::Mash::Rash.new(title: 'white house photo 2', url: 'http://www.flickr.com/photos/35591378@N03/2', thumbnail_url: 'http://thumbnailurl2')]
        search_response.end_record = 2
      end
    end

    before do
      affiliate.flickr_profiles << flickr_profiles(:user)
      oasis_search = instance_double(OasisSearch)
      allow(OasisSearch).to receive(:new).and_return oasis_search
      allow(oasis_search).to receive(:execute_query).and_return search_engine_response
    end

    context 'when query is present' do
      before do
        get '/search/images.json', params: { affiliate: affiliate.name, query: 'white house' }
      end

      it 'responds with search results from Oasis' do
        json_response = response.parsed_body
        expect(json_response['total']).to eq(2)
        expect(json_response['startrecord']).to eq(1)
        expect(json_response['endrecord']).to eq(2)

        json_response['results'].each do |r|
          expect(r['title']).to start_with('white house photo')
          expect(r['url']).to start_with('http://www.flickr.com/photos/35591378@N03/')
        end
      end
    end

    context 'when query is blank' do
      before do
        get '/search/images.json', params: { affiliate: affiliate.name, query: ' ' }
      end

      it 'responds with error message' do
        json_response = response.parsed_body
        expect(json_response['error']).to eq('Please enter a search term in the box above.')
      end
    end
  end
end
