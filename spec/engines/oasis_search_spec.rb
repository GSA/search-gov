# coding: utf-8
require 'spec_helper'

describe OasisSearch do

  context 'when results are available' do
    let(:image_search) { OasisSearch.new(query: "shuttle") }

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