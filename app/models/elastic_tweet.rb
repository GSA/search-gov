class ElasticTweet
  extend Indexable

  self.settings = ElasticSettings::COMMON

  self.mappings = {
    index_type => {
      dynamic: :strict,
      properties: {
        language: { type: 'keyword', index: true },
        twitter_profile_id: { type: 'long' },
        tweet_text: { type: 'text', term_vector: 'with_positions_offsets' },
        published_at: { type: 'date' },
        id: { type: 'long' }
      }
    }
  }

end
