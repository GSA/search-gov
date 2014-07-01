class ElasticFederalRegisterDocument
  extend Indexable

  self.settings = ElasticSettings::COMMON

  self.mappings = {
    index_type => {
      dynamic: :strict,
      analyzer: 'en_analyzer',
      properties: {
        abstract: { type: 'string', term_vector: 'with_positions_offsets' },
        comments_close_on: { type: 'date', format: 'date' },
        document_number: ElasticSettings::KEYWORD,
        federal_register_agency_ids: { type: 'integer' },
        title: { type: 'string', term_vector: 'with_positions_offsets' },
        id: { type: 'integer', index: :not_analyzed, include_in_all: false }
      }
    }
  }

end
