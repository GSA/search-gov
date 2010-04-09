require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RecallsController do
  describe "#index" do
    context "when all parameters specified" do
      before do
        @search = mock(Sunspot::Search)
        @search.stub!(:total).and_return 1
        @search.stub!(:results).and_return [{:key1=>"val1"}, {:key2=>"val2"}]
        @query_string = 'stroller'
        @page = "2"
        valid_options = %w{start_date end_date upc sort code organization make model year}
        @valid_options_hash = valid_options.inject({}) { |s, e| s.merge( { e.to_s => "MY_#{e.upcase}" } ) }
        @valid_params = @valid_options_hash.merge(:format => 'json', :query => @query_string, :page => @page)
      end

      it "should perform a search with the relevant parameters passed in" do
        Recall.should_receive(:search_for).with(@query_string, @valid_options_hash, @page).and_return(@search)
        param_to_be_ignored = {:ignore_me => "foo bar"}
        get :index, @valid_params.merge(param_to_be_ignored)
      end

      it "should return parsable JSON" do
        Recall.stub!(:search_for).and_return(@search)
        get :index, @valid_params
        parsed_response = JSON.parse(response.body)
        parsed_response["success"]["total"].should == 1
        parsed_response["success"]["results"].should == [{"key1"=>"val1"}, {"key2"=>"val2"}]
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