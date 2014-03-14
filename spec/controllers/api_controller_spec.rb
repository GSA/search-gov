require 'spec_helper'

describe ApiController do
  fixtures :affiliates, :users, :site_domains, :features

  describe "#search" do
    let(:affiliate) { affiliates(:basic_affiliate) }

    context "when the affiliate does not exist" do
      before { get :search, affiliate: 'missingaffiliate' }

      it { should respond_with :not_found }
    end

    context 'when the params[:affiliate] is not a string' do
      before { get :search, affiliate: {'foo' => 'bar'} }

      it { should respond_with :not_found }
    end

    describe "with format=json" do

      before do
        json = {result_field: 'result'}.to_json
        ApiSearch.should_receive(:search).with(hash_including(affiliate: affiliate, query: 'solar')).and_return(json)
        get :search, :affiliate => affiliate.name, :format => 'json', :query => 'solar'
      end

      it { should respond_with_content_type :json }
      it { should respond_with :success }
      it { should be_ssl_allowed }

      describe "response body" do
        subject { JSON.parse(response.body) }
        its(['result_field']) { should == 'result' }
      end
    end

    context "with format=xml" do

      before do
        xml = {result_field: 'result'}.to_xml
        ApiSearch.should_receive(:search).with(hash_including(affiliate: affiliate, query: 'solar')).and_return(xml)
        get :search, :affiliate => affiliate.name, :format => 'xml', :query => 'solar'
      end

      it { should respond_with_content_type :xml }
      it { should respond_with :success }

      describe "response body" do
        subject { Hash.from_xml(response.body)['hash'] }

        its(['result_field']) { should == 'result' }
      end
    end

    context "with format=html" do
      before do
        get :search, :affiliate => affiliate.name, :format => :html
      end

      it { should respond_with :not_acceptable }
    end

    describe "options" do
      before :each do
        @auth_params = {:affiliate => affiliates(:basic_affiliate).name}
      end

      it "should set the affiliate" do
        get :search, @auth_params
        assigns[:search_options][:affiliate].should == affiliates(:basic_affiliate)
      end

      context 'when affiliate search engine is Google' do
        before do
          affiliates(:basic_affiliate).search_engine = 'Google'
        end

        it "should set the affiliate search engine to Bing" do
          get :search, @auth_params
          assigns[:search_options][:affiliate].search_engine.should == 'Bing'
        end
      end

      it "should set the query" do
        get :search, @auth_params.merge(:query => "fish")
        assigns[:search_options][:query].should == "fish"
      end

      it "should set the lat_lon" do
        get :search, @auth_params.merge(:query => "fish", :lat_lon => '37.7676,-122.5164')
        assigns[:search_options][:lat_lon].should == "37.7676,-122.5164"
      end
    end

    describe "jsonp support" do
      it "should wrap response with predefined callback if callback is not blank" do
        affiliate = affiliates(:basic_affiliate)
        search_results = {:spelling_suggestions => "house"}.to_json
        ApiSearch.should_receive(:search).and_return(search_results)
        get :search, :affiliate => affiliate.name, :query => "haus", :callback => 'processData', :format => 'json'
        response.body.should == %{processData({"spelling_suggestions":"house"})}
      end
    end

  end

end
