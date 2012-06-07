require 'spec/spec_helper'

describe Tweet do
  before do
    @valid_attributes = {
      :tweet_id => 18700887835,
      :tweet_text => "got a lovely surprise from @craftybeans. She sent me the best tshirt ever. http://www.flickr.com/photos/cindyli/4799054041/ ::giggles::",
      :published_at => Time.now
    }
  end
  
  it { should validate_presence_of :tweet_id }
  it { should validate_presence_of :tweet_text }
  it { should validate_presence_of :published_at }
  it { should validate_presence_of :twitter_profile_id }
  
  it "should create new instance give valid attributes" do
    profile = TwitterProfile.create!(:twitter_id => 12345, :screen_name => 'USASearch')
    tweet = Tweet.create!(@valid_attributes.merge(:twitter_profile_id => profile.id))
    tweet.tweet_id.should == @valid_attributes[:tweet_id]
    tweet.tweet_text.should == @valid_attributes[:tweet_text]
  
    should validate_uniqueness_of :tweet_id 
  end
  
  describe "#search_for" do
    before do
      now = Time.now
      Tweet.destroy_all
      Tweet.create!(:tweet_id => 1234567, :tweet_text => "Good morning, America!", :published_at => now, :twitter_profile_id => 12345)
      Tweet.create!(:tweet_id => 2345678, :tweet_text => "Good morning, America!", :published_at => now - 10.seconds, :twitter_profile_id => 23456)
      Tweet.create!(:tweet_id => 3456789, :tweet_text => "Hello, America!", :published_at => now - 1.hour, :twitter_profile_id => 12345)
      Tweet.reindex
    end
    
    it "should find the most recent tweet that matches the term(s) queried from any of the Twitter accounts specified" do
      search = Tweet.search_for("america", [12345, 23456])
      search.total.should == 3
      search.results.size.should == 1
      search.results.first.tweet_text.should == "Good morning, America!"
      search.results.first.twitter_profile_id.should == 12345
    end
    
    it "should not find results from Twitter accounts not specified" do
      search = Tweet.search_for("america", [23456])
      search.total.should == 1
      search.results.size.should == 1
      search.results.first.tweet_text.should == "Good morning, America!"
      search.results.first.twitter_profile_id.should == 23456
    end
    
    context "when specifying a page/per_page value" do
      it "should page the results accordingly" do
        search = Tweet.search_for("america", [12345, 23456], 2, 2)
        search.total.should == 3
        search.results.size.should == 1
        search.results.first.tweet_text.should == "Hello, America!"
        search.results.first.twitter_profile_id.should == 12345
      end
    end
    
    context "when a blank search is entered" do
      before do
        @search = FlickrPhoto.search_for("", @affiliate)
      end
      
      it "should return nil" do
        @search.should be_nil
      end
    end
  end
  
  describe "#link_to_tweet" do
    before do
      profile = TwitterProfile.create!(:twitter_id => 12345, :screen_name => 'USASearch')
      @tweet = Tweet.create!(:tweet_text => "USA", :tweet_id => 123456, :published_at => Time.now, :twitter_profile_id => 12345)
    end
    
    it "should output a properly formatted link to the tweet" do
      @tweet.link_to_tweet.should == "http://twitter.com/#!/USASearch/status/123456"
    end
  end
end
