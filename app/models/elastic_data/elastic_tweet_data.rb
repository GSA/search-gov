# frozen_string_literal: true

class ElasticTweetData
  attr_reader :tweet, :language

  def initialize(tweet)
    @tweet = tweet
    @language = tweet.language
  end

  def to_builder
    Jbuilder.new do |json|
      json.(tweet, :id, :twitter_profile_id)
      json.set! "tweet_text.#{language}", tweet.tweet_text
      json.published_at tweet.published_at.strftime('%Y-%m-%dT%H:%M:%S')
      json.language language
    end
  end
end
