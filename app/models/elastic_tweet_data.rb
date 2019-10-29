class ElasticTweetData

  def initialize(tweet)
    @tweet = tweet
  end

  def to_builder
    Jbuilder.new do |json|
      json.(@tweet, :id, :twitter_profile_id, :tweet_text)
      json.published_at @tweet.published_at.strftime("%Y-%m-%dT%H:%M:%S")
      json.language "#{@tweet.language}_analyzer"
    end
  end

end