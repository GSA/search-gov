require 'spec_helper'

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
    profile = TwitterProfile.create!(:twitter_id => 12345,
                                     :screen_name => 'USASearch',
                                     :name => 'USASearch',
                                     :profile_image_url => 'http://a0.twimg.com/profile_images/1879738641/USASearch_avatar_normal.png')
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

    it "should find the 3 most recent tweets that matches the term(s) queried from any of the Twitter accounts specified" do
      search = Tweet.search_for("america", [12345, 23456])
      search.total.should == 3
      search.results.size.should == 3
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
      specify { Tweet.search_for('', [23456]).should be_nil }
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

  describe "with t.co links" do
    it "should convert a t.co url to a full URL" do
      # I happen to know this t.co link will resolve to a meetup page
      tweet = Tweet.create!(:tweet_text => "http://t.co/vuvfH6To", :tweet_id => 123456, :published_at => Time.now, :twitter_profile_id => 12345)
      tweet.tweet_text.should == "http://www.meetup.com/bmore-on-rails/events/78736452/"
    end

    it "should convert many and various t.co urls to full URLs" do
      tweet = Tweet.create!(:tweet_text => "Ohai, I'm a toot link: http://t.co/vuvfH6To, and some other stuff http://t.co/zlVONdxi!", :tweet_id => 123456, :published_at => Time.now, :twitter_profile_id => 12345)
      tweet.tweet_text.should == "Ohai, I'm a toot link: http://www.meetup.com/bmore-on-rails/events/78736452/, and some other stuff http://www.youtube.com/watch?v=3g4ekwTd6Ig!"
    end

    it "should efficiently convert the same URL appearing more than once" do
      tweet = Tweet.new(:tweet_text => "link 1: http://t.co/vuvfH6To, link 2: http://t.co/vuvfH6To, link 3: http://t.co/vuvfH6To", :tweet_id => 123456, :published_at => Time.now, :twitter_profile_id => 12345)
      Net::HTTP.should_receive(:start).with("t.co", 80).once.and_return({'location' => 'http://www.meetup.com/bmore-on-rails/events/78736452/'})
      tweet.save!
      tweet.tweet_text.should == "link 1: http://www.meetup.com/bmore-on-rails/events/78736452/, link 2: http://www.meetup.com/bmore-on-rails/events/78736452/, link 3: http://www.meetup.com/bmore-on-rails/events/78736452/"
    end

    it "should not mess with non-t.co links" do
      tweet = Tweet.new(:tweet_text => "I'm an imposter! http://ted.co/vuvfH6To! Yaaaaay!", :tweet_id => 123456, :published_at => Time.now, :twitter_profile_id => 12345)
      Net::HTTP.should_not_receive(:start)
      tweet.save!
      tweet.tweet_text.should == "I'm an imposter! http://ted.co/vuvfH6To! Yaaaaay!"
    end
  end
end
