require 'spec/spec_helper'

describe ApiSearch do
  fixtures :affiliates

  describe ".search" do
    context "format is json" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:api_redis) { ApiSearch.redis }
      let(:format) { 'json' }
      let(:params) { { :query => "foobar", :page => 2, :results_per_page => 10, :affiliate => affiliate, :format => format } }
      let(:search) { mock('search') }
      let(:search_result_in_json) { mock('search_result_in_json') }

      before :each do
        Search.should_receive(:new).with(params).and_return(search)
        search.should_receive(:cache_key).and_return("search_cache_key")
        @api_cache_key = "API:#{affiliate.name}:bing:search_cache_key:#{format.to_s}"
      end

      context "api search cache miss" do
        it "should run search and cache the result" do
          api_redis.should_receive(:get).with(@api_cache_key).and_return(nil)
          search.should_receive(:run)
          search.should_receive(:to_json).and_return(search_result_in_json)
          api_redis.should_receive(:setex).with(@api_cache_key, ApiSearch::CACHE_EXPIRATION_IN_SECONDS, search_result_in_json)

          ApiSearch.search(params).should == search_result_in_json
        end
      end

      context "api search cache hit" do
        it "should not run search" do
          api_redis.should_receive(:get).with(@api_cache_key).and_return(search_result_in_json)
          api_redis.should_not_receive(:setex)
          search.should_not_receive(:run)

          ApiSearch.search(params).should == search_result_in_json
        end
      end

      context "when retrieving from cache raises Error" do
        it "should run search and cache the result" do
          api_redis.should_receive(:get).with(@api_cache_key).and_raise(StandardError)
          search.should_receive(:run)
          search.should_receive(:to_json).and_return(search_result_in_json)
          api_redis.should_receive(:setex).with(@api_cache_key, ApiSearch::CACHE_EXPIRATION_IN_SECONDS, search_result_in_json)

          ApiSearch.search(params).should == search_result_in_json
        end
      end

      context "when caching result raises Error" do
        it "should run search and cache the result" do
          api_redis.should_receive(:get).with(@api_cache_key).and_return(nil)
          search.should_receive(:run)
          search.should_receive(:to_json).and_return(search_result_in_json)
          api_redis.should_receive(:setex).with(@api_cache_key, ApiSearch::CACHE_EXPIRATION_IN_SECONDS, search_result_in_json).and_raise(StandardError)

          ApiSearch.search(params).should == search_result_in_json
        end
      end
    end

    context "format is xml" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:api_redis) { ApiSearch.redis }
      let(:format) { 'xml' }
      let(:params) { { :query => "foobar", :page => 2, :results_per_page => 10, :affiliate => affiliate, :format => format } }
      let(:search) { mock('search') }
      let(:search_result_in_xml) { mock('search_result_in_xml') }

      before :each do
        Search.should_receive(:new).with(params).and_return(search)
        search.should_receive(:cache_key).and_return("search_cache_key")
        @api_cache_key = "API:#{affiliate.name}:bing:search_cache_key:#{format.to_s}"
      end

      context "api search cache miss" do
        it "should run search and cache the result" do
          api_redis.should_receive(:get).with(@api_cache_key).and_return(nil)
          search.should_receive(:run)
          search.should_receive(:to_xml).and_return(search_result_in_xml)
          api_redis.should_receive(:setex).with(@api_cache_key, ApiSearch::CACHE_EXPIRATION_IN_SECONDS, search_result_in_xml)

          ApiSearch.search(params).should == search_result_in_xml
        end
      end

      context "api search cache hit" do
        it "should not run search" do
          api_redis.should_receive(:get).with(@api_cache_key).and_return(search_result_in_xml)
          api_redis.should_not_receive(:setex)
          search.should_not_receive(:run)

          ApiSearch.search(params).should == search_result_in_xml
        end
      end

      context "when retrieving from cache raises Error" do
        it "should run search and cache the result" do
          api_redis.should_receive(:get).with(@api_cache_key).and_raise(StandardError)
          search.should_receive(:run)
          search.should_receive(:to_xml).and_return(search_result_in_xml)
          api_redis.should_receive(:setex).with(@api_cache_key, ApiSearch::CACHE_EXPIRATION_IN_SECONDS, search_result_in_xml)

          ApiSearch.search(params).should == search_result_in_xml
        end
      end

      context "when caching result raises Error" do
        it "should run search and cache the result" do
          api_redis.should_receive(:get).with(@api_cache_key).and_return(nil)
          search.should_receive(:run)
          search.should_receive(:to_xml).and_return(search_result_in_xml)
          api_redis.should_receive(:setex).with(@api_cache_key, ApiSearch::CACHE_EXPIRATION_IN_SECONDS, search_result_in_xml).and_raise(StandardError)

          ApiSearch.search(params).should == search_result_in_xml
        end
      end
    end
    
    context "source is 'odie'" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:api_redis) { ApiSearch.redis }
      let(:format) { 'json' }
      let(:index) { 'odie' }
      let(:params) { { :query => "foobar", :page => 0, :results_per_page => 10, :affiliate => affiliate, :format => format, :index => index } }
      let(:search) { mock(OdieSearch) }
      let(:search_result_in_json) { mock('search_result_in_json') }
      
      before do
        search.stub!(:cache_key).and_return("search_cache_key")
        search.stub!(:run)
        search.stub!(:to_json).and_return search_result_in_json
      end
      
      it "should not create a new Search object, but create an OdieSearch object instead" do
        api_redis.should_receive(:get).with("API:#{affiliate.name}:odie:search_cache_key:#{format.to_s}").and_return(nil)
        Search.should_not_receive(:new)
        OdieSearch.should_receive(:new).with(params.merge(:page => 1)).and_return(search)
        ApiSearch.search(params)
      end
    end
  end
end
