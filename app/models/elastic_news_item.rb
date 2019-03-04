class ElasticNewsItem
  extend Indexable
  DUBLIN_CORE_AGG_NAMES = [:contributor, :subject, :publisher]

  self.settings = ElasticSettings::COMMON

  self.mappings = {
    index_type => {
      dynamic: :strict,
      _analyzer: { path: "language" },
      properties: {
        language: { type: 'keyword', index: true },
        rss_feed_url_id: { type: 'integer' },
        title: { type: 'string', term_vector: 'with_positions_offsets', copy_to: 'bigram' },
        description: { type: 'string', term_vector: 'with_positions_offsets', copy_to: 'bigram' },
        body: { type: 'string', term_vector: 'with_positions_offsets', copy_to: 'bigram' },
        published_at: { type: 'date' },
        popularity: { type: 'integer' },
        link: ElasticSettings::KEYWORD,
        contributor: { type: 'string', analyzer: 'keyword' },
        subject: { type: 'string', analyzer: 'keyword' },
        publisher: { type: 'string', analyzer: 'keyword' },
        bigram: { type: 'string', analyzer: 'bigram_analyzer'},
        tags: { type: 'string', analyzer: 'keyword' },
        id: { type: 'integer' } }
    }
  }

end
