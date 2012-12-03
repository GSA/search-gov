require 'spec_helper'

describe ApiSearch do
  fixtures :affiliates

  describe ".search" do
    context "format is json" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:api_redis) { ApiSearch.redis }
      let(:format) { 'json' }
      let(:params) { {:query => "foobar", :page => 2, :per_page => 10, :affiliate => affiliate, :format => format} }
      let(:search) { mock(WebSearch) }
      let(:search_result_in_json) { mock('search_result_in_json') }

      before :each do
        WebSearch.should_receive(:new).with(params).and_return(search)
        search.should_receive(:cache_key).and_return("search_cache_key")
        @api_cache_key = ['API', 'WebSearch', 'search_cache_key', format.to_s].join(':')
      end

      context "when api search cache miss" do
        it "should run search and cache the result" do
          api_redis.should_receive(:get).with(@api_cache_key).and_return(nil)
          search.should_receive(:run)
          search.should_receive(:to_json).and_return(search_result_in_json)
          api_redis.should_receive(:setex).with(@api_cache_key, ApiSearch::CACHE_EXPIRATION_IN_SECONDS, search_result_in_json)

          ApiSearch.search(params).should == search_result_in_json
        end
      end

      context "when api search cache hit" do
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

    context "when format is xml" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:api_redis) { ApiSearch.redis }
      let(:format) { 'xml' }
      let(:params) { {:query => "foobar", :page => 2, :per_page => 10, :affiliate => affiliate, :format => format} }
      let(:search) { mock(WebSearch) }
      let(:search_result_in_xml) { mock('search_result_in_xml') }

      before :each do
        WebSearch.should_receive(:new).with(params).and_return(search)
        search.should_receive(:cache_key).and_return("search_cache_key")
        @api_cache_key = ['API', 'WebSearch', 'search_cache_key', format.to_s].join(':')
      end

      context "when api search has a cache miss" do
        it "should run search and cache the result" do
          api_redis.should_receive(:get).with(@api_cache_key).and_return(nil)
          search.should_receive(:run)
          search.should_receive(:to_xml).and_return(search_result_in_xml)
          api_redis.should_receive(:setex).with(@api_cache_key, ApiSearch::CACHE_EXPIRATION_IN_SECONDS, search_result_in_xml)

          ApiSearch.search(params).should == search_result_in_xml
        end
      end

      context "when api search cache hit" do
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

    describe "handling of source index" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:api_redis) { ApiSearch.redis }
      let(:format) { 'json' }
      let(:params) { {:query => "foobar", :page => 1, :per_page => 10, :affiliate => affiliate, :format => format} }
      let(:search) { mock(WebSearch) }

      before do
        search.stub!(:cache_key).and_return("search_cache_key")
        search.stub!(:run)
        search.stub!(:to_json).and_return "search_result_in_json"
      end

      context "when it's web" do
        it "should create a WebSearch object" do
          WebSearch.should_receive(:new).with(params.merge(:index => 'web')).and_return(search)
          ApiSearch.search(params.merge(:index => 'web'))
        end
      end

      context "when it's undefined" do
        it "should create a WebSearch object" do
          WebSearch.should_receive(:new).with(params).and_return(search)
          ApiSearch.search(params)
        end
      end

      context "when it's news" do
        it "should create a NewsSearch object" do
          NewsSearch.should_receive(:new).with(params.merge(:index => 'news')).and_return(search)
          ApiSearch.search(params.merge(:index => 'news'))
        end
      end

      context "when it's videonews" do
        it "should create a VideoNewsSearch object" do
          VideoNewsSearch.should_receive(:new).with(params.merge(:index => 'videonews')).and_return(search)
          ApiSearch.search(params.merge(:index => 'videonews'))
        end
      end

      context "when it's images" do
        it "should create an ImageSearch object" do
          ImageSearch.should_receive(:new).with(params.merge(:index => 'images')).and_return(search)
          ApiSearch.search(params.merge(:index => 'images'))
        end
      end

      context "when it's document collections (docs)" do
        it "should create a SiteSearch object" do
          SiteSearch.should_receive(:new).with(params.merge(:index => 'docs', :dc => '45')).and_return(search)
          ApiSearch.search(params.merge(:index => 'docs', :dc => '45'))
        end
      end
    end

  end
end
