# frozen_string_literal: true

class ElasticTweetResults < ElasticResults

  def highlight_instance(highlight, instance)
    instance.tweet_text = highlight['tweet_text'].first if highlight['tweet_text']
    instance
  end

end