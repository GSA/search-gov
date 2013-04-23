# coding: utf-8
require 'spec_helper'

describe GoogleImageSearch do

  context 'when results are available' do
    let(:image_search) { GoogleImageSearch.new(query: "obama", enable_highlighting: false) }

    it "should return a response" do
      normalized_response = image_search.execute_query
      normalized_response.start_record.should == 1
      normalized_response.end_record.should == 10
      normalized_response.total.should == 570000
      first = normalized_response.results.first
      first.title.should == "New official portrait released | Change.gov: The Obama-Biden ..."
      first.width.should == 1916
      first.height.should == 2608
      first.file_size.should == 803500
      first.content_type.should == 'image/jpeg'
      first.url.should == 'http://change.gov/page/-/officialportrait.jpg'
      first.display_url.should == 'change.gov'
      first.media_url.should == 'http://change.gov/page/-/officialportrait.jpg'
      thumbnail = first.thumbnail
      thumbnail.url.should == 'https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcQZHqReHyW7m47-cBp1ln3d3sCvxE2b5MqoXtFpU3vMVQaz-mcKRL4CjUQ'
      thumbnail.height.should == 150
      thumbnail.width.should == 110
    end
  end

end