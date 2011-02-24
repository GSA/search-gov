require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApiController do
  fixtures :affiliates, :affiliate_templates, :users

  describe "#search" do
    describe "authentication" do
      it "should 401 when there is no api key" do
        get :search, :affiliate_name => affiliates(:basic_affiliate).name

        response.code.should == "401"
      end

      it "should 401 when there is a blank api key" do
        get :search, :affiliate_name => affiliates(:basic_affiliate).name, :api_key => ""

        response.code.should == "401"
      end

      it "should 401 when there is an unknown api key" do
        get :search, :affiliate_name => affiliates(:basic_affiliate).name, :api_key => "bad_api_key"

        response.code.should == "401"
      end

      it "should 403 when there is a valid api key, but for the wrong affiliate" do
        get :search, :affiliate_name => affiliates(:basic_affiliate).name, :api_key => users(:another_affiliate_manager).api_key

        response.code.should == "403"
      end

      it "should 403 when there is a valid api key, but no affiliate found" do
        get :search, :affiliate_name => "bad_affiliate_name", :api_key => users(:another_affiliate_manager).api_key

        response.code.should == "403"
      end

      it "should be a success if correct affiliate name and api key" do
        get :search, :affiliate_name => affiliates(:basic_affiliate).name, :api_key => users(:affiliate_manager).api_key

        response.should be_success
      end
    end

    describe "options" do
      before :each do
        get :search, :affiliate_name => affiliates(:basic_affiliate).name, :api_key => users(:affiliate_manager).api_key, :query => "fish"
      end

      it "should set the affiliate" do
        assigns[:search_options][:affiliate].should == affiliates(:basic_affiliate)
      end

      it "should set the query" do
        assigns[:search_options][:query].should == "fish"
      end
    end

    describe "boosted content" do
      it "should include boosted content if found" do
        affiliate = affiliates(:basic_affiliate)
        affiliate.boosted_contents.create!(:title => "title", :url => "http://example.com", :description => "description")
        BoostedContent.reindex

        get :search, :affiliate_name => affiliate.name, :api_key => users(:affiliate_manager).api_key, :query => "title"

        boosted_results = JSON.parse(response.body)["boosted_results"]
        boosted_results.should_not be_blank
        boosted_results.length.should == 1
        boosted_results.first["title"].should == "title"
        boosted_results.first["url"].should == "http://example.com"
        boosted_results.first["description"].should == "description"
      end
    end

  end

end
