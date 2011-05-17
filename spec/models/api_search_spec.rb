require 'spec/spec_helper'

describe ApiSearch do
  describe "caching" do
    fixtures :affiliates
    before :each do
      @api_redis = ApiSearch.redis
      @search_redis = Search.send(:class_variable_get, :@@redis)
      @affiliate = affiliates(:basic_affiliate)
      @params = {:query => "foobar", :page => 2, :results_per_page => 10, :affiliate => @affiliate}
      @search_cache_key = Search.new(@params).cache_key
      @api_cache_key = "API:#{@affiliate.name}:#{@search_cache_key}"
      @bing_json = File.read(Rails.root.to_s + "/spec/fixtures/json/bing_search_results_with_spelling_suggestions.json")
    end

    describe "api search cache miss" do
      it "should store the new result in the api cache" do
        @api_redis.should_receive(:get).with(@api_cache_key).and_return(nil)
        @api_redis.should_receive(:setex).with(@api_cache_key, ApiSearch::CACHE_EXPIRATION_IN_SECONDS, an_instance_of(String))

        @search_redis.should_receive(:get).with(@search_cache_key).and_return(@bing_json)
        @search_redis.should_not_receive(:setex)

        result = ApiSearch.search(@params)
        parsed_results = JSON.parse(result)
        parsed_results.keys.should =~ %w{results spelling_suggestions startrecord related total endrecord boosted_results}
      end
    end

    describe "api search cache hit" do
      it "should save the search's json in the cache" do
        @api_redis.should_receive(:get).with(@api_cache_key).and_return("result")
        @api_redis.should_not_receive(:setex)

        @search_redis.should_not_receive(:get)
        @search_redis.should_not_receive(:setex)
        ApiSearch.search(@params).should == "result"
      end
    end

    describe "redis errors" do
      it "should ignore get errors" do
        @api_redis.should_receive(:get).and_raise(Errno::ECONNREFUSED)
        @api_redis.should_receive(:setex).with(@api_cache_key, ApiSearch::CACHE_EXPIRATION_IN_SECONDS, an_instance_of(String))
        @search_redis.should_receive(:get).with(@search_cache_key).and_return(@bing_json)

        JSON.parse(ApiSearch.search(@params)).keys.length.should == 7
      end

      it "should ignore setex errors" do
        @api_redis.should_receive(:get).with(@api_cache_key).and_return(nil)
        @api_redis.should_receive(:setex).and_raise(Errno::ECONNREFUSED)
        @search_redis.should_receive(:get).with(@search_cache_key).and_return(@bing_json)

        JSON.parse(ApiSearch.search(@params)).keys.length.should == 7
      end
    end
  end
end
