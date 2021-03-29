# frozen_string_literal: true

describe Tweet do
  let(:twitter_profile) { twitter_profiles(:usasearch) }
  let(:valid_attributes) do
    {
      tweet_id: 18700887835,
      tweet_text: 'this is a tweet',
      published_at: Time.now,
      twitter_profile_id: twitter_profile.id
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

  describe 'schema' do
    it { is_expected.to have_db_index(:published_at) }
  end

  it 'creates new instance given valid attributes' do
    tweet = described_class.create!(valid_attributes.merge(twitter_profile_id: profile.id))
    expect(tweet.tweet_id).to eq(valid_attributes[:tweet_id])
    expect(tweet.tweet_text).to eq(valid_attributes[:tweet_text])

    is_expected.to validate_uniqueness_of :tweet_id
  end

  it 'sanitizes tweet text' do
    tweet = described_class.create!(tweet_text: "A <b>tweet</b> with \n http://t.co/h5vNlSdL and http://t.co/YQQSs9bb",
                          tweet_id: 123456,
                          published_at: Time.now,
                          twitter_profile_id: 12345)
    expect(described_class.find(tweet.id).tweet_text).to eq('A tweet with http://t.co/h5vNlSdL and http://t.co/YQQSs9bb')
  end

  describe '#language' do
    context 'when tweet can be traced back to at least one affiliate' do
      before do
        profile.affiliates << affiliates(:gobiernousa_affiliate)
        @tweet = profile.tweets.create!(valid_attributes)
      end

      it 'uses the locale for the first affiliate' do
        expect(@tweet.language).to eq('es')
      end
    end

    context 'when tweet cannot be traced back to at least one affiliate' do
      before do
        @tweet = described_class.create!(valid_attributes.merge(twitter_profile_id: profile.id))
      end

      it 'uses English' do
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
      @tweet = described_class.create!(tweet_text: 'USA', tweet_id: 123456, published_at: Time.now, twitter_profile_id: 12345)
    end

    it 'outputs a properly formatted link to the tweet' do
      expect(@tweet.url_to_tweet).to eq('https://twitter.com/USASearch/status/123456')
    end
  end

  describe '.expire(days_back)' do
    subject(:expire) { described_class.expire(3) }

    context 'when tweets exist' do
      before do
        described_class.create!(
          valid_attributes.merge(
            tweet_text: 'old tweet', published_at: 4.days.ago, tweet_id: 1
          )
        )
        described_class.create!(
          valid_attributes.merge(
            tweet_text: 'new tweet', published_at: 1.minute.ago, tweet_id: 2
          )
        )
      end

      it 'destroys tweets that were published more than X days ago' do
        expire
        expect(described_class.pluck(:tweet_text)).to eq ['new tweet']
      end
    end
  end
end
