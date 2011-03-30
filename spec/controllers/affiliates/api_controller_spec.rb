require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Affiliates::ApiController do
  fixtures :affiliates, :affiliate_templates, :users

  before do
    activate_authlogic
  end

  describe "#search" do
    describe "authentication" do
      it "should 401 when there is no api key" do
        get :search, :affiliate => affiliates(:basic_affiliate).name

        response.code.should == "401"
      end

      it "should 401 when there is a blank api key" do
        get :search, :affiliate => affiliates(:basic_affiliate).name, :api_key => ""

        response.code.should == "401"
      end

      it "should 401 when there is an unknown api key" do
        get :search, :affiliate => affiliates(:basic_affiliate).name, :api_key => "bad_api_key"

        response.code.should == "401"
      end

      it "should 403 when there is a valid api key, but for the wrong affiliate" do
        get :search, :affiliate => affiliates(:basic_affiliate).name, :api_key => users(:another_affiliate_manager).api_key

        response.code.should == "403"
      end

      it "should 403 when there is a valid api key, but no affiliate found" do
        get :search, :affiliate => "bad_affiliate_name", :api_key => users(:another_affiliate_manager).api_key

        response.code.should == "403"
      end

      it "should be a success if correct affiliate name and api key" do
        get :search, :affiliate => affiliates(:basic_affiliate).name, :api_key => users(:affiliate_manager).api_key

        response.should be_success
      end
    end

    describe "options" do
      before :each do
        @auth_params = {:affiliate => affiliates(:basic_affiliate).name, :api_key => users(:affiliate_manager).api_key}
      end

      it "should set the affiliate" do
        get :search,  @auth_params
        assigns[:search_options][:affiliate].should == affiliates(:basic_affiliate)
      end

      it "should set the query" do
        get :search,  @auth_params.merge(:query => "fish")
        assigns[:search_options][:query].should == "fish"
      end

      describe "paging" do
        it "should set the page to the zero indexed page" do
          get :search,  @auth_params.merge(:page => 3)
          assigns[:search_options][:page].to_i.should == 2
        end

        it "should default the page to -1" do
          get :search,  @auth_params
          assigns[:search_options][:page].to_i.should == -1
        end

        it "should set results_per_page from per-page" do
          get :search,  @auth_params.merge("per-page" => 15)
          assigns[:search_options][:results_per_page].to_i.should == 15
        end
      end
    end

    describe "boosted content" do
      it "should include boosted content if found" do
        affiliate = affiliates(:basic_affiliate)
        affiliate.boosted_contents.create!(:title => "title", :url => "http://example.com", :description => "description")
        BoostedContent.reindex

        get :search, :affiliate => affiliate.name, :api_key => users(:affiliate_manager).api_key, :query => "title"

        boosted_results = JSON.parse(response.body)["boosted_results"]
        boosted_results.should_not be_blank
        boosted_results.length.should == 1
        boosted_results.first["title"].should == "title"
        boosted_results.first["url"].should == "http://example.com"
        boosted_results.first["description"].should == "description"
      end
    end

    describe "jsonp support" do
      it "should wrap response with predefined callback if callback is not blank" do
        affiliate = affiliates(:basic_affiliate)
        search_results = {:spelling_suggestions=> "house"}.to_json
        ApiSearch.should_receive(:search).and_return(search_results)
        get :search, :affiliate => affiliate.name, :api_key => users(:affiliate_manager).api_key, :query => "haus", :callback => 'processData'
        response.body.should == %{processData({"spelling_suggestions":"house"})}
      end
    end

  end

  describe "#index" do
    render_views
    before do
      @user = users(:affiliate_manager)
      UserSession.create(@user)
      @affiliate = affiliates(:basic_affiliate)
    end

    it "should render successfully and display both the affiliate name and the user's api key" do
      get :index, :affiliate_id => @affiliate.id
      response.should be_success

      response.body.should contain(@user.api_key)
      response.body.should contain(@affiliate.name)
    end
  end

end
