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
end
