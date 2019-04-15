class ElasticNewsItem
  extend Indexable
  DUBLIN_CORE_AGG_NAMES = [:contributor, :subject, :publisher]

  self.settings = ElasticSettings::COMMON

  self.mappings = {
    index_type => {
      dynamic: :strict,
      properties: {
        language: { type: 'keyword', index: true },
        rss_feed_url_id: { type: 'integer' },
        title: { type: 'text',
                 term_vector: 'with_positions_offsets',
                 copy_to: 'bigram' },
        description: { type: 'text',
                       term_vector: 'with_positions_offsets',
                       copy_to: 'bigram' },
        body: { type: 'text',
                term_vector: 'with_positions_offsets',
                copy_to: 'bigram' },
        published_at: { type: 'date' },
        popularity: { type: 'integer' },
        link: ElasticSettings::KEYWORD,
        contributor: { type: 'keyword' },
        subject: { type: 'keyword' },
        publisher: { type: 'keyword' },
        bigram: { type: 'text', analyzer: 'bigram_analyzer' },
        tags: { type: 'keyword' },
        id: { type: 'integer' } }
    }
  }

end
