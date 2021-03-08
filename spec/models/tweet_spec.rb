require 'spec_helper'

describe Tweet do
  fixtures :affiliates

  before do
    allow(Twitter).to receive(:user).and_return double('Twitter', id: 12345, name: 'USASearch', profile_image_url: 'http://some.gov/url')
    @valid_attributes = {
      tweet_id: 18700887835,
      tweet_text: 'got a lovely surprise from @craftybeans. She sent me the best tshirt ever. http://www.flickr.com/photos/cindyli/4799054041/ ::giggles::',
      published_at: Time.now
    }
  end

  let(:profile) do
    TwitterProfile.create!(twitter_id: 12345,
                           screen_name: 'USASearch',
                           name: 'USASearch',
                           profile_image_url: 'http://a0.twimg.com/profile_images/1879738641/USASearch_avatar_normal.png')
  end

  it { is_expected.to validate_presence_of :tweet_id }
  it { is_expected.to validate_presence_of :tweet_text }
  it { is_expected.to validate_presence_of :published_at }
  it { is_expected.to validate_presence_of :twitter_profile_id }

  it 'should create new instance given valid attributes' do
    tweet = Tweet.create!(@valid_attributes.merge(twitter_profile_id: profile.id))
    expect(tweet.tweet_id).to eq(@valid_attributes[:tweet_id])
    expect(tweet.tweet_text).to eq(@valid_attributes[:tweet_text])

    is_expected.to validate_uniqueness_of :tweet_id
  end

  it 'should sanitize tweet text' do
    tweet = Tweet.create!(tweet_text: "A <b>tweet</b> with \n http://t.co/h5vNlSdL and http://t.co/YQQSs9bb",
                          tweet_id: 123456,
                          published_at: Time.now,
                          twitter_profile_id: 12345)
    expect(Tweet.find(tweet.id).tweet_text).to eq('A tweet with http://t.co/h5vNlSdL and http://t.co/YQQSs9bb')
  end

  describe '#language' do
    context 'when tweet can be traced back to at least one affiliate' do
      before do
        profile.affiliates << affiliates(:gobiernousa_affiliate)
        @tweet = profile.tweets.create!(@valid_attributes)
      end

      it 'should use the locale for the first affiliate' do
        expect(@tweet.language).to eq('es')
      end
    end

    context 'when tweet cannot be traced back to at least one affiliate' do
      before do
        @tweet = Tweet.create!(@valid_attributes.merge(twitter_profile_id: profile.id))
      end

      it 'should use English' do
        expect(@tweet.language).to eq('en')
      end
    end
  end

  describe '#url_to_tweet' do
    before do
      TwitterProfile.create!(twitter_id: 12345,
                             screen_name: 'USASearch',
                             name: 'USASearch',
                             profile_image_url: 'http://a0.twimg.com/profile_images/1879738641/USASearch_avatar_normal.png')
      @tweet = Tweet.create!(tweet_text: 'USA', tweet_id: 123456, published_at: Time.now, twitter_profile_id: 12345)
    end

    it 'should output a properly formatted link to the tweet' do
      expect(@tweet.url_to_tweet).to eq('https://twitter.com/USASearch/status/123456')
    end
  end

  describe '.expire(days_back)' do
    it 'should destroy tweets that were published more than X days ago' do
      expect(Tweet).to receive(:destroy_all).with(['published_at < ?', 3.days.ago.beginning_of_day.to_s(:db)])
      Tweet.expire(3)
    end
  end

end
