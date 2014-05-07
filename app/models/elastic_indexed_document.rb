class ElasticIndexedDocument
  extend Indexable

  self.settings = ElasticSettings::COMMON.deep_merge(
    index: {
      number_of_shards: 1,
      number_of_replicas: 0
    }
  )

  self.mappings = {
    index_type => ElasticMappings::COMMON.deep_merge(
      properties: {
        title: { type: 'string', term_vector: 'with_positions_offsets', copy_to: 'bigram' },
        description: { type: 'string', term_vector: 'with_positions_offsets', copy_to: 'bigram' },
        body: { type: 'string', term_vector: 'with_positions_offsets', copy_to: 'bigram' },
        published_at: { type: 'date' },
        popularity: { type: 'integer' },
        bigram: { type: 'string', analyzer: 'bigram_analyzer'},
        url: ElasticSettings::KEYWORD
      }
    )
  }

end