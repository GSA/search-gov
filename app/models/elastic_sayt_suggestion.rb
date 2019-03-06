class ElasticSaytSuggestion
  extend Indexable

  self.settings = ElasticSettings::COMMON

  self.mappings = {
    index_type => ElasticMappings::COMMON.deep_merge(
      properties: {
        phrase: {
          type: 'text', term_vector: 'with_positions_offsets',
          fields: { keyword: ElasticSettings::KEYWORD } },
        popularity: { type: 'integer' }
      }
    )
  }

end
