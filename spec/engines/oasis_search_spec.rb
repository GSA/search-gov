require 'spec_helper'

describe OasisSearch do

  context 'when results are available' do
    let(:image_search) { described_class.new(query: 'shuttle') }
    before do
      oasis_api_url = "#{Oasis.host}#{OasisSearch::API_ENDPOINT}?"
      oasis_image_result = Rails.root.join('spec/fixtures/json/oasis/image_search/shuttle.json').read
      image_search_params = { from: 0, query: 'shuttle', size: 10 }
      stub_request(:get, "#{oasis_api_url}#{image_search_params.to_param}").
        to_return( status: 200, body: oasis_image_result )
    end

    it 'should return a response' do
      normalized_response = image_search.execute_query
      expect(normalized_response.start_record).to eq(1)
      expect(normalized_response.end_record).to eq(10)
      expect(normalized_response.total).to eq(14_543)
      first = normalized_response.results.first
      expect(first.title).to eq('Archive: Levan, Albania (Archive: NASA, Space Shuttle, 10/17/02)')
      expect(first.url).to eq('http://www.flickr.com/photos/28634332@N05/14708690681/')
      expect(first.thumbnail_url).to eq('https://farm3.staticflickr.com/2907/14708690681_08d50c642c_q.jpg')
    end
  end

end
