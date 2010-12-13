require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RecallsController do
  describe "#index" do
    context "when all parameters specified" do
      before do
        @redis = RecallsController.send(:class_variable_get, :@@redis)
        @search = mock(Sunspot::Search)
        @search.stub!(:total).and_return 1
        @search.stub!(:results).and_return [{:key1=>"val1"}, {:key2=>"val2"}]
        @query_string = 'stroller'
        @page = "2"
        @valid_options_hash = {"start_date"=> "2010-11-10", "end_date"=> "2010-11-20"}
        @valid_params = @valid_options_hash.merge("format" => 'json', "query" => @query_string, "page" => @page)
      end

      context "when result is not cached" do
        before do
          @redis.stub!(:get).and_return nil
        end

        it "should perform a search with the relevant parameters passed in" do
          Recall.should_receive(:search_for).with(@query_string, @valid_options_hash, @page).and_return(@search)
          param_to_be_ignored = {:ignore_me => "foo bar"}
          get :index, @valid_params.merge(param_to_be_ignored)
        end

        it "should cache the result" do
          @redis.should_receive(:setex).and_return 1
          get :index, :format => 'json'
        end

        it "should return parsable JSON" do
          Recall.stub!(:search_for).and_return(@search)
          get :index, @valid_params
          parsed_response = JSON.parse(response.body)
          parsed_response["success"]["total"].should == 1
          parsed_response["success"]["results"].should == [{"key1"=>"val1"}, {"key2"=>"val2"}]
        end

      end

      context "when result is cached" do
        it "should fetch the result from cache" do
          @redis.should_receive(:get).once.and_return "some valid results in JSON"
          get :index, :format => 'json'
          response.body.should == "some valid results in JSON"
        end
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

    context "when dates are submitted in an invalid format" do
      before do
        @good_date = '2010-5-20'
        @bad_date = '05-20-2010'
        @query = "stroller"
      end

      it "should return a JSON error object" do
        get :index, :query => @query, :start_date => @bad_date, :end_date => @good_date
        parsed_response = JSON.parse(response.body)
        parsed_response["error"].should == "invalid date"
        get :index, :query => @query, :end_date => @bad_date, :start_date => @good_date
        parsed_response = JSON.parse(response.body)
        parsed_response["error"].should == "invalid date"
      end
    end
    
    context "when valid organizations are specified" do
      it "should not return a JSON error object" do
        Recall::VALID_ORGANIZATIONS.each do |organization|
          get :index, :organization => organization
          parsed_response = JSON.parse(response.body)
          parsed_response["error"].should be_nil
        end
      end
    end

    context "when invalid organzation is specified" do
      it "should return a JSON error object" do
        get :index, :organization => "bogus"
        parsed_response = JSON.parse(response.body)
        parsed_response["error"].should == "invalid organization"
      end
    end

    context "when invalid code is specified" do
      it "should return a JSON error object" do
        get :index, :code => "bogus"
        parsed_response = JSON.parse(response.body)
        parsed_response["error"].should == "invalid code"
      end
    end

    context "when invalid year is specified" do
      it "should return a JSON error object" do
        get :index, :year => "bogus"
        parsed_response = JSON.parse(response.body)
        parsed_response["error"].should == "invalid year"
      end
    end

    context "when invalid page is specified" do
      it "should return a JSON error object" do
        get :index, :page => "bogus"
        parsed_response = JSON.parse(response.body)
        parsed_response["error"].should == "invalid page"
      end
    end
  end
end