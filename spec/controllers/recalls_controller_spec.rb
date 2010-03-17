require 'spec_helper'

describe RecallsController do    
  describe "searching for recalls" do
    context "when searching recalls by keyword" do
      before do
        @query_string = 'stroller'
        get :index, :query => @query_string
        @query = assigns[:query]
        @page = assigns[:page]
        @search = assigns[:search]
      end
      
      it "should assign the query parameter to the query variable" do
        @query.should == @query_string
      end
      
      it "should set the page to nil when page is not specified" do
        @page.should == 1
      end
      
      it "should perform a search and return a search object" do
        @search.should_not be_nil
      end
      
      it "should return parsable JSON" do
        parsed_response = JSON.parse(response.body)
        parsed_response.should_not be_nil
      end
    end
    
    context "when paginating through results" do
      before do
        get :index, :query => @query_string, :page => 2
        @page = assigns[:page]
      end

      it "should assign the page parameter to the page variable" do
        @page.should == '2'
      end
    end
          
  end  
end