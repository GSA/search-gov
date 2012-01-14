require 'spec/spec_helper'

describe ApiController do
  fixtures :affiliates, :affiliate_templates, :users

  describe "#search" do
    context "when there is no api key parameter" do
      before do
        get :search, :affiliate => affiliates(:basic_affiliate).name
      end

      it { should respond_with :unauthorized }
    end

    context "when the api key is blank" do
      before do
        get :search, :affiliate => affiliates(:basic_affiliate).name, :api_key => ''
      end

      it { should respond_with :unauthorized }
    end

    context "when the api key is invalid" do
      before do
        get :search, :affiliate => affiliates(:basic_affiliate).name, :api_key => 'bad_api_key'
      end

      it { should respond_with :unauthorized }
    end

    context "when the api key is valid, but for the wrong affiliate" do
      before do
        get :search, :affiliate => affiliates(:basic_affiliate).name, :api_key => users(:another_affiliate_manager).api_key
      end

      it { should respond_with :forbidden }
    end

    context "when the affiliate does not match the api_key affiliate" do
      before do
        get :search, :affiliate => affiliates(:basic_affiliate).name, :api_key => users(:another_affiliate_manager).api_key
      end

      it { should respond_with :forbidden }
    end

    describe "with format=json" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:api_key) { users(:affiliate_manager).api_key }

      before do
        get :search, :affiliate => affiliate.name, :api_key => api_key, :format => 'json', :query => 'solar'
      end

      it { should respond_with_content_type :json }
      it { should respond_with :success }

      describe "response body" do
        subject { JSON.parse(response.body) }
        its(['total']) { should be > 0 }
        its(['startrecord']) { should == 1}
        its(['endrecord']) { should == 10 }
        its(['results']) { should_not be_empty }
      end
    end

    context "with format=xml" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:api_key) { users(:affiliate_manager).api_key }

      before do
        get :search, :affiliate => affiliate.name, :api_key => api_key, :format => 'xml', :query => 'solar'
      end

      it { should respond_with_content_type :xml }
      it { should respond_with :success }

      describe "response body" do
        subject { Hash.from_xml(response.body)["search"] }

        its(['total']) { should be > 0 }
        its(['startrecord']) { should == 1}
        its(['endrecord']) { should == 10 }
        its(['results']) { should_not be_empty }
      end
    end

    context "with format=html" do
      before do
        get :search, :affiliate => affiliates(:basic_affiliate).name, :api_key => users(:affiliate_manager).api_key, :format => :html
      end

      it { should respond_with :not_acceptable }
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
        it "should set the page" do
          get :search,  @auth_params.merge(:page => 3)
          assigns[:search_options][:page].to_i.should == 3
        end

        it "should default the page to 1" do
          get :search,  @auth_params
          assigns[:search_options][:page].to_i.should == 1
        end

        it "should set results_per_page from per-page" do
          get :search,  @auth_params.merge("per-page" => 15)
          assigns[:search_options][:per_page].to_i.should == 15
        end
      end
    end

    describe "boosted content" do
      it "should include boosted content if found" do
        affiliate = affiliates(:basic_affiliate)
        affiliate.boosted_contents.create!(:title => "title",
                                           :url => "http://example.com",
                                           :description => "description",
                                           :locale => 'en',
                                           :status => 'active',
                                           :publish_start_on => Date.current)
        BoostedContent.reindex

        get :search, :affiliate => affiliate.name, :api_key => users(:affiliate_manager).api_key, :query => "title", :format => 'json'

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
        get :search, :affiliate => affiliate.name, :api_key => users(:affiliate_manager).api_key, :query => "haus", :callback => 'processData', :format => 'json'
        response.body.should == %{processData({"spelling_suggestions":"house"})}
      end
    end

  end

end
