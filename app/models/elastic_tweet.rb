# frozen_string_literal: true

class ElasticTweet
  extend Indexable

  self.settings = ElasticSettings::COMMON

  self.mappings = {
    index_type => ElasticMappings::COMMON.deep_merge(
      properties: {
        twitter_profile_id: { type: 'long' },
        tweet_text: ElasticSettings::TEXT,
        published_at: { type: 'date' }
      }
    )
  }
end
