class ElasticIndexedDocument
  extend Indexable

  self.settings = ElasticSettings::COMMON.deep_merge(
    index: {
      number_of_shards: 2,
      number_of_replicas: 0
    }
  )

  self.mappings = {
    index_type => ElasticMappings::COMMON.deep_merge(
      properties: {
        title: { type: 'string', term_vector: 'with_positions_offsets' },
        description: { type: 'string', term_vector: 'with_positions_offsets' },
        body: { type: 'string', term_vector: 'with_positions_offsets' },
        url: ElasticSettings::KEYWORD
      }
    )
  }

end