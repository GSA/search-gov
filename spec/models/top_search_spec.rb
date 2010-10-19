require "#{File.dirname(__FILE__)}/../spec_helper"

describe TopSearch do
  should_validate_presence_of :position, :query
  should_validate_numericality_of :position, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 5
  
  describe "#link_url" do
    before do
      @top_search_with_url = TopSearch.create(:position => 1, :query => 'query', :url => 'http://test.com/')
      @top_search_without_url = TopSearch.create(:position => 2, :query => 'some query')
    end
    
    it "should return the stored url if present" do
      @top_search_with_url.link_url.should == @top_search_with_url.url
    end
    
    it "should return a Search.USA.gov URL with the query URL-escaped if url is not present" do
      @top_search_without_url.link_url.should == "http://search.usa.gov/search?query=some+query&linked=1"
    end
  end
end