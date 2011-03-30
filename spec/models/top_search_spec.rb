require "#{File.dirname(__FILE__)}/../spec_helper"

describe TopSearch do
  it { should validate_presence_of :position }
  it { should validate_numericality_of :position }
  it { should ensure_inclusion_of(:position).in_range(1..5).with_low_message(/must be greater than or equal/).with_high_message(/must be less than or equal/) }

  describe "#save" do
    it "should set query to nil if query is blank" do
      top_search = TopSearch.create!(:position => 1, :query => '  ')
      top_search.query.should be_nil
    end
  end

  describe "#find_active_entries" do
    it "should retrieve 5 entries with query that is not null, sorted by position in ascending order" do
      TopSearch.should_receive(:all).with(:conditions => "query IS NOT NULL", :order => "position ASC", :limit => 5)
      TopSearch.find_active_entries
    end
  end

  describe "#link_url" do
    before do
      @top_search_with_url = TopSearch.create(:position => 1, :query => 'query', :url => 'http://test.com/')
      @top_search_without_url = TopSearch.create(:position => 2, :query => 'some query')
    end
    
    it "should return the stored url if present" do
      @top_search_with_url.link_url.should == @top_search_with_url.url
    end
    
    it "should return a Search.USA.gov URL with the query URL-escaped if url is not present" do
      @top_search_without_url.link_url.should == "http://search.usa.gov/search?query=some+query&linked=1&position=2"
    end
  end
end