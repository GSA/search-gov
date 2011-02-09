require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RecallsController do
  
  describe "#index" do
    context "when making a request for a request without a format (or HTML)" do
      it "should render the html template" do
        get :index, :query => 'strollers'
        response.should be_success
      end
      
      it "should not care about an API key" do
        get :index, :query => 'strollers', :api_key => 'bad api key'
        response.should be_success
      end
      
      context "when all parameters specified" do
        before do
          @search = mock(Sunspot::Search)
          @search.stub!(:total).and_return 1
          @search.stub!(:results).and_return [{:key1=>"val1"}, {:key2=>"val2"}]
          @query_string = 'stroller'
          @page = "2"
          @valid_options_hash = {"start_date"=> "2010-11-10", "end_date"=> "2010-11-20", "sort" => 'date'}
          @valid_params = @valid_options_hash.merge(:query => @query_string, :page => @page)
        end

        it "should perform a search with the relevant parameters passed in" do
          Recall.should_receive(:search_for).with(@query_string, @valid_options_hash, @page).and_return(@search)
          param_to_be_ignored = {:ignore_me => "foo bar"}
          get :index, @valid_params.merge(param_to_be_ignored)
        end

        it "should not do any caching of the result" do
          @redis.should be_nil
          get :index, @valid_params
        end
      end
      
      context "when a date range is supplied" do
        it "should set the start and end date to appropriate values for each of the values" do
          get :index, :date_range => 'last_30'
          assigns[:valid_params][:start_date].should == Date.today - 30.days
          assigns[:valid_params][:end_date].should == Date.today
          get :index, :date_range => 'last_90'
          assigns[:valid_params][:start_date].should == Date.today - 90.days
          assigns[:valid_params][:end_date].should == Date.today
          get :index, :date_range => 'current_year'
          assigns[:valid_params][:start_date].should == Date.parse("#{Date.today.year}-01-01")
          assigns[:valid_params][:end_date].should == Date.today
          get :index, :date_range => 'last_year'
          assigns[:valid_params][:start_date].should == Date.parse("#{Date.today.year - 1}-01-01")
          assigns[:valid_params][:end_date].should == Date.parse("#{Date.today.year - 1}-12-31")
        end
      end
      
      context "when no sort value is defined" do
        it "should default to searching by date" do
          get :index
          assigns[:valid_params][:sort].should == 'rel'
        end
      end
    end
    
    context "when requesting JSON results" do
      before do
        @developer = User.new(:email => 'developer@usa.gov', :contact_name => 'USA.gov Developer', :password => 'password', :password_confirmation => 'password', :government_affiliation => "0")
        @developer.save
      end
      
      context "when an API key is specified" do
        it "should check that the API key belongs to a user, and process the request" do
          User.should_receive(:find_by_api_key).with(@developer.api_key).and_return @developer
          get :index, :query => 'stroller', :api_key => @developer.api_key, :format => 'json'
          response.should be_success
        end
      
        it "should return a 401 error if the key is not found" do
          User.should_receive(:find_by_api_key).with('badkey').and_return nil
          get :index, :query => 'stroller', :api_key => 'badkey', :format => 'json'
          response.should_not be_success
        end
      
        it "should not care if the API key is not specified" do
          get :index, :query => 'stroller', :format => 'json'
          response.should be_success
        end
      end
    
      context "when all parameters specified" do
        before do
          @redis = RecallsController.send(:class_variable_get, :@@redis)
          @search = mock(Sunspot::Search)
          @search.stub!(:total).and_return 1
          @search.stub!(:results).and_return [{:key1=>"val1"}, {:key2=>"val2"}]
          @query_string = 'stroller'
          @page = "2"
          @valid_options_hash = {"start_date"=> "2010-11-10", "end_date"=> "2010-11-20"}
          @valid_params = @valid_options_hash.merge(:query => @query_string, :page => @page, :api_key => @developer.api_key, :format => 'json')
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
            get :index, @valid_params
          end

          context "when JSON results are requested" do
            it "should return parsable JSON" do
              Recall.stub!(:search_for).and_return(@search)
              get :index, @valid_params.merge(:format => 'json')
              parsed_response = JSON.parse(response.body)
              parsed_response["success"]["total"].should == 1
              parsed_response["success"]["results"].should == [{"key1"=>"val1"}, {"key2"=>"val2"}]
            end
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
      
      context "when dates are submitted in an invalid format" do
        before do
          @good_date = '2010-5-20'
          @bad_date = '05-20-2010'
          @query = "stroller"
        end

        it "should return a JSON error object" do
          get :index, :query => @query, :end_date => @bad_date, :start_date => @good_date, :format => 'json'
          parsed_response = JSON.parse(response.body)
          parsed_response["error"].should == "Invalid date"
        end
      end
    
      context "when valid organizations are specified" do
        it "should not return a JSON error object" do
          Recall::VALID_ORGANIZATIONS.each do |organization|
            get :index, :organization => organization, :format => 'json'
            parsed_response = JSON.parse(response.body)
            parsed_response["error"].should be_nil
          end
        end
      end

      context "when invalid organzation is specified" do
        it "should return a JSON error object" do
          get :index, :organization => "bogus", :format => 'json'
          parsed_response = JSON.parse(response.body)
          parsed_response["error"].should == "Invalid organization"
        end
      end

      context "when invalid code is specified" do
        it "should return a JSON error object" do
          get :index, :code => "bogus", :format => 'json'
          parsed_response = JSON.parse(response.body)
          parsed_response["error"].should == "Invalid code"
        end
      end

      context "when invalid year is specified" do
        it "should return a JSON error object" do
          get :index, :year => "bogus", :format => 'json'
          parsed_response = JSON.parse(response.body)
          parsed_response["error"].should == "Invalid year"
        end
      end

      context "when invalid page is specified" do
        it "should return a JSON error object" do
          get :index, :page => "bogus", :format => 'json'
          parsed_response = JSON.parse(response.body)
          parsed_response["error"].should == "Invalid page"
        end
      end
      
      context "when an invalid date range is specified" do
        it "should return a JSON error object" do
          get :index, :date_range => 'all', :format => 'json'
          parsed_response = JSON.parse(response.body)
          parsed_response["error"].should == "Invalid date range"
        end
      end
    end
    
    context "when no sort value is specified" do
      it "should not set a sort value" do
        get :index, :format => 'json'
        assigns[:valid_params][:sort].should be_nil
      end
    end
    
    context "when making a request with some other format, besides json" do
      before do
        get :index, :query => 'strollers', :format => 'wml'
      end

      it "should return an error message" do
        response.body.should contain('Not Implemented')
      end
      
      it "should return an error status of 501" do
        response.status.should == "501 Not Implemented"
      end
    end
    
  end
end
