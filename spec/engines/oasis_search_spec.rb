# coding: utf-8
require 'spec_helper'

describe OasisSearch do

  context 'when results are available' do
    let(:image_search) { OasisSearch.new(query: "shuttle") }
    before do
      oasis_api_url = "http://#{Oasis.host}#{OasisSearch::API_ENDPOINT}?"
      oasis_image_result = Rails.root.join('spec/fixtures/json/oasis/image_search/shuttle.json').read
      image_search_params = { from: 0, query: 'shuttle', size: 10 }
      stub_request(:get, "#{oasis_api_url}#{image_search_params.to_param}").
        to_return( status: 200, body: oasis_image_result )
    end

    it "should return a response" do
      normalized_response = image_search.execute_query
      normalized_response.start_record.should == 1
      normalized_response.end_record.should == 10
      normalized_response.total.should == 14543
      first = normalized_response.results.first
      first.title.should == "Archive: Levan, Albania (Archive: NASA, Space Shuttle, 10/17/02)"
      first.url.should == 'http://www.flickr.com/photos/28634332@N05/14708690681/'
      first.thumbnail_url.should == 'https://farm3.staticflickr.com/2907/14708690681_08d50c642c_q.jpg'
    end
  end

end
