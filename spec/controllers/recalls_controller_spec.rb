require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RecallsController do
  before(:all) do
    @search = mock(Sunspot::Search)
    @search.stub!(:total).and_return 0
    @search.stub!(:results).and_return nil
    Recall.stub!(:search_for).and_return @search
  end

  describe "searching for recalls" do
    context "when searching recalls by keyword" do
      before do
        @query_string = 'stroller'
        get :index, :query => @query_string, :format => 'json'
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
        get :index, :query => @query_string, :page => 2, :format => 'json'
        @page = assigns[:page]
      end

      it "should assign the page parameter to the page variable" do
        @page.should == '2'
      end
    end

    context "when searching with a date range" do
      before do
        get :index, :start_date => '2010-01-01', :end_date => '2010-03-18', :format => 'json'
        @start_date = assigns[:start_date]
        @end_date = assigns[:end_date]
      end

      it "should assign the start date" do
        @start_date.should == '2010-01-01'
      end

      it "should assign the end date" do
        @end_date.should == '2010-03-18'
      end
    end

    context "when making a request with some other format, besides json" do
      before do
        get :index, :query => 'strollers', :format => 'html'
      end

      it "should return an error message" do
        response.body.should contain('Not Implemented')
      end
    end
  end
end