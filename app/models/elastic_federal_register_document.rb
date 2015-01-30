class ElasticFederalRegisterDocument
  extend Indexable
  OPTIMIZING_INCLUDES = [:federal_register_agencies].freeze

  self.settings = ElasticSettings::COMMON.deep_merge(
    index: {
      number_of_shards: 1,
      number_of_replicas: 0
    }
  )

  self.mappings = {
    index_type => {
      dynamic: :strict,
      analyzer: 'en_analyzer',
      properties: {
        abstract: { type: 'string', term_vector: 'with_positions_offsets' },
        comments_close_on: { type: 'date', format: 'date' },
        publication_date: { type: 'date', format: 'date' },
        group_id: ElasticSettings::KEYWORD,
        document_number: ElasticSettings::KEYWORD,
        document_type: ElasticSettings::KEYWORD,
        federal_register_agency_ids: { type: 'integer' },
        title: { type: 'string', term_vector: 'with_positions_offsets' },
        significant: { type: 'boolean'},
        id: { type: 'integer', index: :not_analyzed, include_in_all: false }
      }
    }
  }

end
