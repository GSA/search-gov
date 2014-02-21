class ElasticIndexedDocument
  extend Indexable

  self.settings = ElasticSettings::COMMON

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