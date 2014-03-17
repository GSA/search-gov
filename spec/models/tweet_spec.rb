require 'spec_helper'

describe Tweet do
  fixtures :affiliates

  before do
    Twitter.stub!(:user).and_return mock('Twitter', :id => 12345, :name => 'USASearch', :profile_image_url => 'http://some.gov/url')
    @valid_attributes = {
      :tweet_id => 18700887835,
      :tweet_text => "got a lovely surprise from @craftybeans. She sent me the best tshirt ever. http://www.flickr.com/photos/cindyli/4799054041/ ::giggles::",
      :published_at => Time.now
    }
  end

  let(:profile) do
    TwitterProfile.create!(:twitter_id => 12345,
                           :screen_name => 'USASearch',
                           :name => 'USASearch',
                           :profile_image_url => 'http://a0.twimg.com/profile_images/1879738641/USASearch_avatar_normal.png')
  end

  it { should validate_presence_of :tweet_id }
  it { should validate_presence_of :tweet_text }
  it { should validate_presence_of :published_at }
  it { should validate_presence_of :twitter_profile_id }

  it "should create new instance given valid attributes" do
    tweet = Tweet.create!(@valid_attributes.merge(:twitter_profile_id => profile.id))
    tweet.tweet_id.should == @valid_attributes[:tweet_id]
    tweet.tweet_text.should == @valid_attributes[:tweet_text]

    should validate_uniqueness_of :tweet_id
  end

  it 'should sanitize tweet text' do
    tweet = Tweet.create!(:tweet_text => "A <b>tweet</b> with \n http://t.co/h5vNlSdL and http://t.co/YQQSs9bb",
                          :tweet_id => 123456,
                          :published_at => Time.now,
                          :twitter_profile_id => 12345)
    Tweet.find(tweet.id).tweet_text.should == 'A tweet with http://t.co/h5vNlSdL and http://t.co/YQQSs9bb'
  end

  describe "#language" do
    context 'when tweet can be traced back to at least one affiliate' do
      before do
        profile.affiliates << affiliates(:gobiernousa_affiliate)
        @tweet = profile.tweets.create!(@valid_attributes)
      end

      it 'should use the locale for the first affiliate' do
        @tweet.language.should == 'es'
      end
    end

    context 'when tweet cannot be traced back to at least one affiliate' do
      before do
        @tweet = Tweet.create!(@valid_attributes.merge(:twitter_profile_id => profile.id))
      end

      it 'should use English' do
        @tweet.language.should == 'en'
      end
    end
  end

  describe "#link_to_tweet" do
    before do
      TwitterProfile.create!(:twitter_id => 12345,
                             :screen_name => 'USASearch',
                             :name => 'USASearch',
                             :profile_image_url => 'http://a0.twimg.com/profile_images/1879738641/USASearch_avatar_normal.png')
      @tweet = Tweet.create!(:tweet_text => "USA", :tweet_id => 123456, :published_at => Time.now, :twitter_profile_id => 12345)
    end

    it "should output a properly formatted link to the tweet" do
      @tweet.link_to_tweet.should == "http://twitter.com/USASearch/status/123456"
    end
  end
end
