require 'spec/spec_helper'

describe RecallsController do
  describe "#index" do
    context "when rendering the page" do
      render_views
      before do
        get :index
      end

      it "should succeed" do
        response.should be_success
      end

      it "should assign the page title to nothing" do
        assigns[:page_title].should be_nil
      end

      it "should set the page title to 'Search.USA.gov Forms'" do
        response.should have_selector("title", :content => 'Search.USA.gov Recalls')
      end

      it "should have meta tags for description and keywords" do
        response.should have_selector("meta[name=description]")
        response.should have_selector("meta[name=keywords]")
      end
    end

    it "should fetch recent recalls" do
      search = ["latest recall", "second latest recall"]
      Recall.should_receive(:search_for).with("", {:sort => 'date'}).and_return(search)
      get :index
      assigns[:latest_recalls].should == search
    end
  end

  describe "#search" do
    context "for a normal request" do
      render_views
      before do
        Recall.destroy_all
        Recall.reindex
        get :search, :query => 'strollers'
      end

      it "should render the template" do
        response.should render_template 'recalls/search'
        response.should render_template 'layouts/application'
      end

      it "should assign the query with a forms prefix as the page title" do
        assigns[:page_title].should == "strollers"
      end

      it "should show a custom title for the results page" do
        response.body.should contain("strollers - Search.USA.gov Recalls")
      end
    end

    context "when making a request for a request without a format (or HTML)" do
      it "should render the html template" do
        get :search, :query => 'strollers'
        response.should be_success
      end

      it "should not care about an API key" do
        get :search, :query => 'strollers', :api_key => 'bad api key'
        response.should be_success
      end

      context "when all parameters specified" do
        before do
          @query_string = 'stroller'
          @page = "2"
          @valid_options_hash = {"start_date"=> "2010-11-10", "end_date"=> "2010-11-20", "sort" => 'date'}
          @valid_params = @valid_options_hash.merge(:query => @query_string, :page => @page)

          @search = mock(Sunspot::Search)
          @search.stub!(:total).and_return 1

          @per_page = 10
          @total_pages = 1
          hits = stub("Hits")
          hits.stub!(:current_page).and_return @page.to_i
          hits.stub!(:per_page).and_return @per_page
          @search.stub!(:hits).and_return(hits)

          results = stub("Results")
          results.stub!(:total_pages).and_return @total_pages
          @search.stub!(:results).and_return(results)

          WillPaginate::Collection.should_receive(:create).with(@page.to_i, @per_page, @total_pages * @per_page)
          Recall.should_receive(:search_for).with(@query_string, @valid_options_hash, @page).and_return(@search)
        end

        it "should perform a search with the relevant parameters passed in" do
          param_to_be_ignored = {:ignore_me => "foo bar"}
          get :search, @valid_params.merge(param_to_be_ignored)
        end

        it "should not do any caching of the result" do
          @redis.should be_nil
          get :search, @valid_params
        end
      end

      context "when a date range is supplied" do
        it "should set the start and end date to appropriate values for each of the values" do
          get :search, :date_range => 'last_30'
          assigns[:valid_params][:start_date].should == Date.current - 30.days
          assigns[:valid_params][:end_date].should == Date.current
          get :search, :date_range => 'last_90'
          assigns[:valid_params][:start_date].should == Date.current - 90.days
          assigns[:valid_params][:end_date].should == Date.current
          get :search, :date_range => 'current_year'
          assigns[:valid_params][:start_date].should == Date.parse("#{Date.current.year}-01-01")
          assigns[:valid_params][:end_date].should == Date.current
          get :search, :date_range => 'last_year'
          assigns[:valid_params][:start_date].should == Date.parse("#{Date.current.year - 1}-01-01")
          assigns[:valid_params][:end_date].should == Date.parse("#{Date.current.year - 1}-12-31")
        end
      end

      context "when no sort value is defined" do
        it "should default to searching by date" do
          get :search, :query => "beef"
          assigns[:valid_params][:sort].should == 'rel'
        end
      end

      context "when the query is blank" do
        it "should redirect to the landing page" do
          get :search
          response.should redirect_to recalls_path
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
          get :search, :query => 'stroller', :api_key => @developer.api_key, :format => 'json'
          response.should be_success
        end

        it "should return a 401 error if the key is not found" do
          User.should_receive(:find_by_api_key).with('badkey').and_return nil
          get :search, :query => 'stroller', :api_key => 'badkey', :format => 'json'
          response.should_not be_success
        end

        it "should not care if the API key is not specified" do
          get :search, :query => 'stroller', :format => 'json'
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
            get :search, @valid_params.merge(param_to_be_ignored)
          end

          it "should cache the result" do
            @redis.should_receive(:setex).and_return 1
            get :search, @valid_params
          end

          context "when JSON results are requested" do
            it "should return parsable JSON" do
              Recall.stub!(:search_for).and_return(@search)
              get :search, @valid_params.merge(:format => 'json')
              parsed_response = JSON.parse(response.body)
              parsed_response["success"]["total"].should == 1
              parsed_response["success"]["results"].should == [{"key1"=>"val1"}, {"key2"=>"val2"}]
            end
          end
        end

        context "when result is cached" do
          it "should fetch the result from cache" do
            @redis.should_receive(:get).once.and_return "some valid results in JSON"
            get :search, :format => 'json'
            response.body.should == "some valid results in JSON"
          end
        end
      end

      context "when SOLR search returns nil" do
        context "for a JSON search" do
          it "should return empty results" do
            Recall.stub!(:search_for).and_return(nil)

            get :search, :format => "json", :query => "no results", :page => "1"

            response.should be_success
            parsed_response = JSON.parse(response.body)
            parsed_response["success"]["total"].should == 0
            parsed_response["success"]["results"].should == []
          end
        end

        context "for an HTML search" do
          it "should return empty results" do
            Recall.stub!(:search_for).and_return(nil)

            get :search, :query => "no results", :page => 1

            response.should be_success
          end

        end
      end

      context "when a date is submitted in an invalid format" do
        before do
          @good_date = '2010-5-20'
          @bad_date = '05-20-2010'
          @query = "stroller"
        end

        it "should return a JSON error object" do
          get :search, :query => @query, :end_date => @bad_date, :start_date => @good_date, :format => 'json'
          parsed_response = JSON.parse(response.body)
          parsed_response["error"].should == "Invalid date"
          get :search, :query => @query, :end_date => @good_date, :start_date => @bad_date, :format => 'json'
          parsed_response = JSON.parse(response.body)
          parsed_response["error"].should == "Invalid date"
        end
      end

      context "when an invalid date is submitted" do
        before do
          @good_date = '2010-5-20'
          @bad_date = '2010-0-23'
          @query = "stroller"
        end

        it "should return a JSON error object" do
          get :search, :query => @query, :end_date => @bad_date, :start_date => @good_date, :format => 'json'
          parsed_response = JSON.parse(response.body)
          parsed_response["error"].should == "Invalid date"
          get :search, :query => @query, :end_date => @good_date, :start_date => @bad_date, :format => 'json'
          parsed_response = JSON.parse(response.body)
          parsed_response["error"].should == "Invalid date"
        end
      end

      context "when valid organizations are specified" do
        it "should not return a JSON error object" do
          Recall::VALID_ORGANIZATIONS.each do |organization|
            get :search, :organization => organization, :format => 'json'
            parsed_response = JSON.parse(response.body)
            parsed_response["error"].should be_nil
          end
        end
      end

      context "when invalid organzation is specified" do
        it "should return a JSON error object" do
          get :search, :organization => "bogus", :format => 'json'
          parsed_response = JSON.parse(response.body)
          parsed_response["error"].should == "Invalid organization"
        end
      end

      context "when invalid code is specified" do
        it "should return a JSON error object" do
          get :search, :code => "bogus", :format => 'json'
          parsed_response = JSON.parse(response.body)
          parsed_response["error"].should == "Invalid code"
        end
      end

      context "when invalid year is specified" do
        it "should return a JSON error object" do
          get :search, :year => "bogus", :format => 'json'
          parsed_response = JSON.parse(response.body)
          parsed_response["error"].should == "Invalid year"
        end
      end

      context "when invalid page is specified" do
        it "should return a JSON error object" do
          get :search, :page => "bogus", :format => 'json'
          parsed_response = JSON.parse(response.body)
          parsed_response["error"].should == "Invalid page"
        end
      end

      context "when an invalid date range is specified" do
        it "should return a JSON error object" do
          get :search, :date_range => 'all', :format => 'json'
          parsed_response = JSON.parse(response.body)
          parsed_response["error"].should == "Invalid date range"
        end
      end
    end

    context "when no sort value is specified" do
      it "should not set a sort value" do
        get :search, :format => 'json'
        assigns[:valid_params][:sort].should be_nil
      end
    end

    context "when there are a lot of results" do
      before do
        @max_pages = RecallsController::MAX_PAGES
        @page = @max_pages - 2
        @per_page = 10

        @search = mock(Sunspot::Search)

        hits = stub("Hits")
        hits.stub!(:current_page).and_return(@page)
        hits.stub!(:per_page).and_return(@per_page)
        @search.stub!(:hits).and_return(hits)

        results = stub("Results")
        results.stub!(:total_pages).and_return(1000)
        @search.stub!(:results).and_return(results)

        @valid_options_hash = {"sort" => "rel"}
      end

      it "should not allow people to page past the MAX_PAGE limit" do
        Recall.should_receive(:search_for).with("strollers", @valid_options_hash, @page).and_return(@search)
        WillPaginate::Collection.should_receive(:create).with(@page, @per_page, @max_pages * @per_page)
        get :search, :query => 'strollers', :page => @page
      end
    end
  end
end
