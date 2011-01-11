require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe WidgetsController do

  describe "#top_searches" do
    before do
      TopSearch.delete_all
      1.upto(5) do |index|
        TopSearch.create!(:position => index, :query => "Top Search #{index}")
      end
    end
  
    it "should assign the top searches to the top 5 positions" do
      get :top_searches
      assigns[:top_searches].is_a?(Array).should be_true
      assigns[:top_searches].size.should == 5
      0.upto(4) do |index|
        assigns[:top_searches][index].query.should == "Top Search #{index + 1}"
      end
    end
  end
end

